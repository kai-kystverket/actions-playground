package schema

import (
	git "cue.dev/x/githubactions"
	"encoding/yaml"
)

_changesID: "changes"

// Conditionally runs workflows based on which paths are modified
#Changes: git.#Workflow.#normalJob & {
	_changesMap: {...}
	name:      _changesID
	"runs-on": "ubuntu-latest"
	outputs: {
		for job, _ in _changesMap {
			"\(job)": "${{ steps.\(_changesID).outputs.\(job) }}"
		}
	}
	steps: [
		{
			uses: "actions/checkout@v4"
		},
		{
			uses: "dorny/paths-filter@de90cc6fb38fc0963ad72b210f1f284cd68cea36"
			id:   _changesID
			with: filters: {
				yaml.Marshal(_changesMap)
			}
		},
	]
}
