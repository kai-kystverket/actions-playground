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

	// Create reusable terraform actions
	for job in C.jobs if job.type == "terraform" {
		"\(_reusablePreviewIac)": #ReusablePreviewIac
		"\(_reusableApplyIac)":   #ReusableApplyIac
	}

	//
	// // create reusable docker actions
	// for job in C.jobs if job.type == "docker" {
	// 	reusable_preview_iac: #ReusablePreviewIac
	// 	reusable_apply_iac:   #ReusableApplyIac
	// }
	//
	if len(C.paths) > 0 {
		main: git.#Workflow & {
			"on": {
				push: paths: C.paths
			}
			name: "main"
			jobs: changes: #Changes & {
				_changesMap: C.pathsMap
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
				for env, requires in job.envs {
					jobs: "\(job.name)-\(job.pull_request.name)-\(env)": job.pull_request & {
						if: "needs.\(_changesID).changes.outputs.\(job.name) == 'true'"
						if requires != "" {
							needs: list.Concat([[_changesID], ["\(requires)"]])
						}
						if requires == "" {
							needs: [_changesID]
						}
					}
				}
			}
		}
	}
}
