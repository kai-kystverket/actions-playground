package schema

import (
	git "cue.dev/x/githubactions"
	"encoding/yaml"
)

_changesID: "changes"

#Changes: git.#Workflow.#normalJob & {
	_changesMap: {...}
	name:      "changes"
	"runs-on": "ubuntu-latest"
	outputs:
		changes: "${{ steps.\(_changesID).outputs.changes }}"
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
