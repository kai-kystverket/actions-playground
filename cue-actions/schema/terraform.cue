@experiment(aliasv2)
package schema

import (
	git "cue.dev/x/githubactions"
)

_reusablePreviewIac: "reusable-preview-iac"
_reusableApplyIac:   "reusable-apply-iac"

#Terraform: #Job & {
	type: "terraform"
	paths: [...string] | *[
		"terraform/*.tf",
		"terraform/*.hcl",
		"terraform/*.tfvars",
	]
	pull_request: git.#Job & {
		name: string | *"preview"
		uses: "./\(_reusablePreviewIac).yaml"
		with: {
			// "github-environment": string
			"tf-workspace": string | *"default"
			"tf-varfile":   string | *""
			"tf-path":      string | *"terraform"
		}
	}
	main: git.#Job & {
		name: string | *"deploy"
		uses: "./\(_reusableApplyIac).yaml"
		with: {
			// "github-environment": string
			"tf-workspace": string | *"default"
			"tf-varfile":   string | *""
			"tf-path":      string | *"terraform"
		}
	}
}

#ReusablePreviewIac: git.#Workflow & {
	name: "reusable Preview Infrastructure"
	on: workflow_call: inputs: {
		"github-environment": {
			required: true
			type:     "string"
		}
		"tf-workspace": {
			required: false
			type:     "string"
		}
		"tf-varfile": {
			required: false
			type:     "string"
		}
		"tf-path": {
			required: false
			type:     "string"
			default:  "terraform"
		}
	}
	permissions: {
		"id-token":      "write"
		contents:        "read"
		"pull-requests": "write"
	}
	jobs: terraform: {
		"runs-on":         "ubuntu-latest"
		"timeout-minutes": 15
		environment:       "${{ inputs.github-environment }}"
		steps: [
			{
				name:  "fake preview"
				shell: "bash"
				run: """
					echo input: terraform-workspace=${{ inputs.tf-workspace }}
					echo input: variable-file=${{ inputs.tf-varfile }}
					echo input: working-directory=${{ inputs.tf-path}}
					echo input: github-environment=${{ inputs.github-environment}}
					"""
			},
		]
	}
}

#ReusableApplyIac: git.#Workflow & {
	name: "reusable Apply Infrastructure"
	on: workflow_call: inputs: {
		"github-environment": {
			required: true
			type:     "string"
		}
		"tf-workspace": {
			required: false
			type:     "string"
		}
		"tf-varfile": {
			required: false
			type:     "string"
		}
		"tf-path": {
			required: false
			type:     "string"
			default:  "terraform"
		}
	}
	permissions: {
		"id-token": "write"
		contents:   "read"
	}
	jobs: terraform: {
		"runs-on":         "ubuntu-latest"
		"timeout-minutes": 15
		environment:       "${{ inputs.github-environment }}"
		steps: [
			{
				name:  "fake apply"
				shell: "bash"
				run: """
					echo input: terraform-workspace=${{ inputs.tf-workspace }}
					echo input: variable-file=${{ inputs.tf-varfile }}
					echo input: working-directory=${{ inputs.tf-path}}
					echo input: github-environment=${{ inputs.github-environment}}
					"""
			},
		]
	}
}
