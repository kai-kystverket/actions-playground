package schema

import (
	git "cue.dev/x/githubactions"
	"list"
	"encoding/yaml"
)

_filter: "filter"

#SuperDeploy: {
	config: {
		jobs: [...#Job]
	}
	let C = config
	paths: {
		// for job in _jobs if job.type == "terraform" {
		for job in C.jobs {
			"\(job.name)": [for path in job.paths {path}]
		}
	}

	pullRequestPaths: list.Concat([
		for job in C.jobs if job.pull_request != _|_ {
			job.paths
		},
	])

	if len(pullRequestPaths) > 0 {
		reusable_preview_iac: #ReusablePreviewIac
		pull_request: git.#Workflow & {
			"on": {
				pull_request: paths: pullRequestPaths
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
							yaml.Marshal(paths)
						}
					},
				]
			}
			for job in C.jobs if job.pull_request != _|_ {
				for env, requires in job.envs {
					jobs: "\(job.name)-\(job.pull_request.name)-\(env)": job.pull_request & {
						if: "${{ \(_filter).changes.outputs.\(job.name) == 'true' }}"
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
