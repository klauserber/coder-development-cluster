# Cloud cost optimization

Here some points to consider when optimizing cloud costs:

 * **Do not run things you do not use.**
 * Use the right instance type for the right job.
 * Use spot instances for non-critical workloads.

We follow these topics in the deployment of coder development cluster on the Google Cloud Platform.

Here is the picture:

![](./cloud_cost_optimisations.excalidraw.png)

## Base system on low cost instances

We are using a separate node pool for the base system. This node pool is running on low cost instances. Here we are running all components expect the Workspaces.

## Workspaces on performance optimized instances

We are using two separate node pool for the Workspaces. These node pools are running performance optimized instances. The prefered node pool is running spot instances at a much lower cost. The second node pool is running on-demand instances to provide a fallback in case the spot instances are not available.

## Autoscaling

Autoscaling is configured for all node pools. This means that the node pools are automatically scaled up and down based on the current load. This is a great way to save costs when the Workspaces are not used.
