package main

import (
	"context"
	"fmt"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/rds"
)

// Event struct represents the input provided by Cloudwatch event rules
type Event struct {
	Action                 string   `json:"action"`
	DBInstancesIdentifiers []string `json:"dbInstancesIdentifiers"`
}

// HandleRequest starts or stops  an RDS instance
func HandleRequest(ctx context.Context, event Event) (string, error) {
	sess := session.Must(session.NewSessionWithOptions(session.Options{SharedConfigState: session.SharedConfigEnable}))
	rdsSvc := rds.New(sess)

	if len(event.DBInstancesIdentifiers) == 0 {
		return "", fmt.Errorf("No instances ids was passed, nothing to do")
	}

	if event.Action == "startup" {
		return startup(rdsSvc, event)
	}

	if event.Action == "shutdown" {
		return shutdown(rdsSvc, event)
	}

	return "", fmt.Errorf("Unrecognized action '%s': must be either 'startup' or 'shutdown'", event.Action)
}

func startup(rdsSvc *rds.RDS, event Event) (string, error) {
	var startedInstances []string
	var failedInstances []string

	for _, instance := range event.DBInstancesIdentifiers {
		_, err := rdsSvc.StartDBInstance(&rds.StartDBInstanceInput{DBInstanceIdentifier: aws.String(instance)})
		if err != nil {
			fmt.Print(err)
			failedInstances = append(failedInstances, instance)
		} else {
			fmt.Printf("Instance %s started\n", instance)
			startedInstances = append(startedInstances, instance)
		}
	}

	if len(failedInstances) == 0 {
		return fmt.Sprint("Startup suceeded for all instances"), nil
	}
	return "", fmt.Errorf("Some instances failed to start: %+v", failedInstances)
}

func shutdown(rdsSvc *rds.RDS, event Event) (string, error) {
	var stoppedInstances []string
	var failedInstances []string

	for _, instance := range event.DBInstancesIdentifiers {
		_, err := rdsSvc.StopDBInstance(&rds.StopDBInstanceInput{DBInstanceIdentifier: aws.String(instance)})
		if err != nil {
			fmt.Print(err)
			failedInstances = append(failedInstances, instance)
		} else {
			fmt.Printf("Instance %s stopped\n", instance)
			stoppedInstances = append(stoppedInstances, instance)
		}
	}

	if len(failedInstances) == 0 {
		return fmt.Sprint("Shutdown suceeded for all instances"), nil
	}
	return "", fmt.Errorf("Some instances failed to stop: %+v", failedInstances)
}

func main() {
	lambda.Start(HandleRequest)
}
