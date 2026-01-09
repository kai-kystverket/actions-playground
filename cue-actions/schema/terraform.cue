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
	pullRequest: git.#Job & {
		name:        string | *"preview"
		uses:        "./.github/workflows/\(_reusablePreviewIac).yaml"
		permissions: #ReusableTerraformPreview.permissions
		with: {
			// "github-environment": string
			"tf-workspace": string | *"default"
			"tf-varfile":   string | *""
			"tf-path":      string | *"terraform"
		}
	}
	main: git.#Job & {
		name:        string | *"deploy"
		uses:        "./.github/workflows/\(_reusableApplyIac).yaml"
		permissions: #ReusableTerraformApply.permissions
		with: {
			// "github-environment": string
			"tf-workspace": string | *"default"
			"tf-varfile":   string | *""
			"tf-path":      string | *"terraform"
		}
	}
}

#BaseTerraform: git.#Workflow & {
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
	}
}

#ReusableTerraformPreview: #BaseTerraform & {
	name: "reusable Preview Infrastructure"
	permissions: {
		"pull-requests": "write"
	}
	jobs: terraform: steps: [
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

#ReusableTerraformApply: #BaseTerraform & {
	name: "reusable Apply Infrastructure"
	jobs: terraform: steps: [
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
