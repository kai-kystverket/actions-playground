package schema

// Reusable workflow for previewing infrastructure changes (Terraform plan)
// Used for previewing infrastructure changes in different environments, e.g. dev, test, prod
import (
	git "cue.dev/x/githubactions"
)

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
					echo terraform-workspace: ${{ inputs.tf-workspace }}
					echo variable-file: ${{ inputs.tf-varfile }}
					echo working-directory: ${{ inputs.tf-path}}
					echo READ_PACKAGES: ${{ secrets.READ_PACKAGES }}
					"""
			},
		]
	}
}
