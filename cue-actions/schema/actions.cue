package schema

import (
	git "cue.dev/x/githubactions"
	"list"
	"encoding/yaml"
)

_filter: "filter"

#SuperDeploy: {
	let C = config
	config: {
		jobs: [...#Job]

		paths: {
			for job in C.jobs {
				"\(job.name)": [for path in job.paths {path}]
			}
		}

		pullRequestPaths: list.Concat([
			for job in C.jobs if job.pull_request != _|_ {
				job.paths
			},
		])
	}

	for job in C.jobs if job.type == "terraform" {
		reusable_preview_iac: #ReusablePreviewIac
		reusable_apply_iac:   #ReusableApplyIac
	}

	if len(C.pullRequestPaths) > 0 {
		pull_request: git.#Workflow & {
			"on": {
				pull_request: paths: C.pullRequestPaths
			}
			name: "pull_reqest"
			jobs: changes: git.#Job & {
				name:      "changes"
				"runs-on": "ubuntu-latest"
				outputs:
					changes: "${{ steps.\(_filter).outputs.changes }}"
				steps: [
					{
						uses: "actions/checkout@v4"
					},
					{
						uses: "dorny/paths-filter@de90cc6fb38fc0963ad72b210f1f284cd68cea36"
						id:   _filter
						with: filters: {
							yaml.Marshal(C.paths)
						}
					},
				]
			}
			for job in C.jobs if job.pull_request != _|_ {
				for env, requires in job.envs {
					jobs: "\(job.name)-\(job.pull_request.name)-\(env)": job.pull_request & {
						if: "needs.\(_filter).changes.outputs.\(job.name) == 'true'"
						if requires != "" {
							needs: list.Concat([[_filter], ["\(requires)"]])
						}
						if requires == "" {
							needs: [_filter]
						}
					}
				}
			}
		}
	}
}
