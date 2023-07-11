// from: https://docs.aws.amazon.com/codedeploy/latest/userguide/tutorial-ecs-with-hooks-create-hooks.html

'use strict'
 
const AWS = require('aws-sdk')
const codedeploy = new AWS.CodeDeploy()
const ecs = new AWS.ECS()
 
exports.handler = (event, context, callback) => {
  // Read the DeploymentId and LifecycleEventHookExecutionId from the event payload
  var deploymentId = event.DeploymentId
  var lifecycleEventHookExecutionId = event.LifecycleEventHookExecutionId
  var validationTestResult = "Succeeded"
  var clusterName = "skills-cluster"
  var serviceName = "skills-svc"

  // Perform AfterAllowTestTraffic validation tests here.
  const listTasksParams = {
    cluster: clusterName,
    serviceName: serviceName
  };

  ecs.listTasks(listTasksParams, (_, response) => {
    if (response.taskArns.length === 0) {
      console.log('No tasks found in the specified service.');
      return;
    }
  
    // Retrieve the detailed task information
    const describeTasksParams = {
      cluster: clusterName,
      tasks: response.taskArns
    }
  
    ecs.describeTasks(describeTasksParams, (__, { tasks }) => {
      const unhealthy = tasks.find((v) => v.healthStatus === "UNHEALTHY")
    
      if (!!unhealthy) validationTestResult = "Failed"
    
      // Complete the AfterAllowTestTraffic hook by sending CodeDeploy the validation status
      var params = {
        deploymentId: deploymentId,
        lifecycleEventHookExecutionId: lifecycleEventHookExecutionId,
        status: validationTestResult // status can be 'Succeeded' or 'Failed'
      }
    
      // Pass CodeDeploy the prepared validation test results.
      codedeploy.putLifecycleEventHookExecutionStatus(params, function() {
        if (validationTestResult === "Failed") {
          console.log('validation tests failed')
          callback("validation tests failed")
        } else {
          console.log("validation tests succeeded")
          callback(null, "validation tests succeeded")
        }
      })
    });
  });
}  
 