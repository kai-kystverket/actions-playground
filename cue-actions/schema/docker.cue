package schema

#Docker: #Job & {
	name: string
	type: "docker"
	build: {
		// Image name to be tagged
		containerfile: string | *"Dockerfile"
		// The directory (context) containing the Dockerfile
		"dockerfile-directory": string | *name
	}
	deploy: {
		// The name of the container app in Azure Container Apps
		"container-app-name": string | *name
		// description: The resource group containing the container app
		"resource-group-name": string
	}
}
