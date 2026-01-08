package schema

import (
	git "cue.dev/x/githubactions"
	"list"
)

// Wraps wokrflows that run on main and pull requests 
// around a change detection flow
#SuperDeploy: {
	let C = config
	config: {
		jobs: {...}

		for job in C.jobs {
			if job.main != _|_ {
				pathsMap: "\(job.name)": [for p in job.paths {p}]
				paths: list.Concat([for l in pathsMap {l}])
			}
			if job.pull_request != _|_ {
				pullRequestPathsMap: "\(job.name)": [for p in job.paths {p}]
				pullRequestPaths: list.Concat([for l in pullRequestPathsMap {l}])
			}
		}

		paths: [...string]
		pullRequestPaths: [...string]
		// paths: list.Concat([for l in pathsMap {l}])
		// pullRequestPaths: list.Concat([for l in C.pullRequestPathsMap {l}])

		// Generate jobs
		for job in C.jobs {
			if job.build != _|_ {
				build: "\(job.name)-\(job.build.name)": job.build & {
					name: "\(job.name)-\(job.build.name)"
					if:   "${{needs.\(_changesID).outputs.\(job.name) == 'true'}}"
					needs: [_changesID]
				}
			}
			for env in job.envs {
				// Create main branch jobs
				if job.main != _|_ {
					mainJobs: "\(job.name)-\(job.main.name)-\(env.name)": job.main & {
						name: "\(job.name)-\(job.main.name)-\(env.name)"
						// id:   "\(job.name)-\(job.main.name)-\(env.name)"
						if: "${{needs.\(_changesID).outputs.\(job.name) == 'true'}}"
						with: "github-environment": env.name
						if env.requires != _|_ {
							if job.build == _|_ {
								needs: ["\(job.name)-\(job.main.name)-\(env.requires)"]
							}
							if job.build != _|_ {
								needs: list.Concat([["\(job.name)-\(job.main.name)-\(env.requires)"], ["\(job.name)-\(job.build.name)"]])
							}
						}
						if env.requires == _|_ {
							if job.build == _|_ {
								needs: [_changesID]
							}
							if job.build != _|_ {
								needs: ["\(job.name)-\(job.build.name)"]
							}
						}
					}
					//  Create jobs for manual deployment
					manualJobs: "\(job.name)-\(job.main.name)-\(env.name)": job.main & {
						if: "${{ github.event.inputs.workflow == '\(job.name)' && github.event.inputs.env == '\(env.name)' }}"
						with: "github-environment": env.name
						name: "\(job.name)-\(job.main.name)-\(env.name)"
					}
				}
				if job.pull_request != _|_ {
					pullRequestJobs: "\(job.name)-\(job.pull_request.name)-\(env.name)": job.pull_request & {
						if: "${{needs.\(_changesID).outputs.\(job.name) == 'true'}}"
						with: "github-environment": env.name
						name: "\(job.name)-\(job.pull_request.name)-\(env.name)"
						if env.requires != _|_ {
							needs: ["\(job.name)-\(job.pull_request.name)-\(env.requires)"]
						}
						if env.requires == _|_ {
							needs: [_changesID]
						}
					}
				}
			}
		}
	}

	for job in C.jobs {
		// Create reusable terraform actions
		if job.type == "terraform" {
			"\(_reusablePreviewIac)": #ReusablePreviewIac
			"\(_reusableApplyIac)":   #ReusableApplyIac
		}

		// create reusable docker actions
		if job.type == "docker" {
			reusable_build:  #ReusableBuild
			reusable_deploy: #ReusableDeploy
		}
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
			jobs: C.build
			jobs: C.mainJobs
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
			jobs: C.manualJobs
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
			jobs: C.pullRequestJobs
		}
	}
}
