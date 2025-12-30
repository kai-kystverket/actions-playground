package schema

import (
	git "cue.dev/x/githubactions"
	"list"
)

#SuperDeploy: {
	let C = config
	config: {
		jobs: {...}

		paths: list.Concat([
			for job in C.jobs if job.main != _|_ {
				job.paths
			},
		])

		pathsMap: {
			for job in C.jobs if job.main != _|_ {
				"\(job.name)": [for path in job.paths {path}]
			}
		}

		pullRequestPaths: list.Concat([
			for job in C.jobs if job.pull_request != _|_ {
				job.paths
			},
		])

		pullRequestPathsMap: {
			for job in C.jobs if job.pull_request != _|_ {
				"\(job.name)": [for path in job.paths {path}]
			}
		}
	}

	for job in C.jobs {
		// Create reusable terraform actions
		if job.type == "terraform" {
			"\(_reusablePreviewIac)": #ReusablePreviewIac
			"\(_reusableApplyIac)":   #ReusableApplyIac
		}
		// // create reusable docker actions
		// if job.type == "docker" {
		// 	reusable_preview_iac: #ReusablePreviewIac
		// 	reusable_apply_iac:   #ReusableApplyIac
		// }
	}

	if len(C.paths) > 0 {
		main: git.#Workflow & {
			"on": {
				push: paths: C.paths
			}
			name: "main"
			jobs: changes: #Changes & {
				_changesMap: C.pathsMap
			}
			for job in C.jobs if job.main != _|_ {
				for env in job.envs {
					jobs: "\(job.name)-\(job.main.name)-\(env.name)": job.main & {
						name: "\(job.name)-\(job.main.name)-\(env.name)"
						if:   "needs.\(_changesID).changes.outputs.\(job.name) == 'true'"
						if env.requires != _|_ {
							needs: list.Concat([[_changesID], ["\(env.requires)"]])
						}
						if env.requires == _|_ {
							needs: [_changesID]
						}
					}
				}
			}
		}
		manual_deploy: git.#Workflow & {
			name: "manual-deploy"
			"on": {
				workflow_dispatch: {
					inputs: {
						workflow: {
							description: "Workflow to apply"
							required:    true
							type:        "choice"
							options: [for job in C.jobs if job.main != _|_ {job.name}]
						}
						env: {
							description: "Workflow to apply"
							required:    true
							type:        "choice"
							options: ["dev", "test", "prod"]
							default: "dev"
						}
					}
				}
			}
			jobs: {
				main: {
					"runs-on": "ubuntu-latest"
					name:      "main"
					steps: [{
						run: "echo $ENV && echo $WORKFLOW"
						env: {
							WORKFLOW: "${{github.event.inputs.workflow}}"
							ENV:      "${{github.event.inputs.env}}"
						}
					}]
				}
			}
			for job in C.jobs if job.main != _|_ {
				for env in job.envs {
					jobs: "\(job.name)-\(job.main.name)-\(env.name)": job.main & {
						if: "${{ github.event.inputs.workflow == '\(job.name)' && github.event.inputs.env == '\(env.name)' }}"
						with: "github-environment": env.name
						name: "\(job.name)-\(job.main.name)-\(env.name)"
					}
				}
			}
		}
	}
	if len(C.pullRequestPaths) > 0 {
		pull_request: git.#Workflow & {
			"on": {
				pull_request: paths: C.pullRequestPaths
			}
			name: "pull_request"
			jobs: changes: #Changes & {
				_changesMap: C.pullRequestPathsMap
			}
			for job in C.jobs if job.pull_request != _|_ {
				for env in job.envs {
					jobs: "\(job.name)-\(job.pull_request.name)-\(env.name)": job.pull_request & {
						if: "needs.\(_changesID).changes.outputs.\(job.name) == 'true'"
						with: "github-environment": env.name
						name: "\(job.name)-\(job.pull_request.name)-\(env.name)"
						if env.requires != _|_ {
							needs: list.Concat([[_changesID], ["\(env.requires)"]])
						}
						if env.requires == _|_ {
							needs: [_changesID]
						}
					}
				}
			}
		}
	}
}
