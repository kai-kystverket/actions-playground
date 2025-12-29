package actions

import (
	"encoding/yaml"
	"tool/file"
)

// actions: "my-repo": schema.#SuperDeploy & {
// 	config: jobs: {
// 		tftest: schema.#Terraform & {}
// 		frontend: schema.#Docker & {}
// 	}
// }

command: render: {
	for repo, superdeploy in actions
	for name, manifest in superdeploy
	if name != "config" {
		"\(repo)-\(name)": {
			dir: file.MkdirAll & {
				path: "_rendered/\(repo)/"
				$dep: remove.$done
			}
			render: file.Create & {
				filename: "_rendered/\(repo)/\(name).yaml"
				contents: yaml.Marshal(manifest)
				$dep:     dir.$done
			}
		}
	}
}
remove: file.RemoveAll & {
	path: "_rendered"
}
