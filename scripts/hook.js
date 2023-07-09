// from: https://docs.aws.amazon.com/codedeploy/latest/userguide/tutorial-ecs-with-hooks-create-hooks.html

'use strict'
 
const AWS = require('aws-sdk')
const codedeploy = new AWS.CodeDeploy({apiVersion: '2014-10-06'})
 
exports.handler = (event, context, callback) => {
  // Read the DeploymentId and LifecycleEventHookExecutionId from the event payload
  var deploymentId = event.DeploymentId
  var lifecycleEventHookExecutionId = event.LifecycleEventHookExecutionId
  var validationTestResult = "Failed"

  // Perform AfterAllowTestTraffic validation tests here.
  console.log(event)


  // Complete the AfterAllowTestTraffic hook by sending CodeDeploy the validation status
  var params = {
    deploymentId: deploymentId,
    lifecycleEventHookExecutionId: lifecycleEventHookExecutionId,
    status: validationTestResult // status can be 'Succeeded' or 'Failed'
  }

  // Pass CodeDeploy the prepared validation test results.
  codedeploy.putLifecycleEventHookExecutionStatus(params, function(err, data) {
    if (err) {
      // Validation failed.
      console.log('validation tests failed')
      console.log(err, err.stack)
      callback("CodeDeploy Status update failed")
    } else {
      // Validation succeeded.
      console.log("validation tests succeeded")
      callback(null, "validation tests succeeded")
    }
  })
}  
 