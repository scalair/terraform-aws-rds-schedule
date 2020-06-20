package main

import (
	"context"
	"fmt"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/rds"
)

// Event struct represents the input provided by
// Cloudwatch event rules
type Event struct {
	Action                 string   `json:"action"`
	DBInstancesIdentifiers []string `json:"dbInstancesIdentifiers"`
}

// HandleRequest starts or stops  an RDS instance
func HandleRequest(ctx context.Context, event Event) error {
	sess := session.Must(session.NewSessionWithOptions(session.Options{SharedConfigState: session.SharedConfigEnable}))
	rdsSvc := rds.New(sess)

	if event.Action == "startup" {
		startup(rdsSvc, event)
	} else if event.Action == "shutdown" {
		shutdown(rdsSvc, event)
	} else {
		return fmt.Errorf("Unrecognized action: must be either 'startup' or 'shutdown'")
	}

	return nil
}

func startup(rdsSvc *rds.RDS, event Event) {
	for _, instance := range event.DBInstancesIdentifiers {
		out, err := rdsSvc.StartDBInstance(&rds.StartDBInstanceInput{
			DBInstanceIdentifier: aws.String(instance),
		})
		if err != nil {
			fmt.Println(err)
			continue
		}
		fmt.Printf("Instance %s started:\n%+v", instance, out)
	}
}

func shutdown(rdsSvc *rds.RDS, event Event) {
	for _, instance := range event.DBInstancesIdentifiers {
		out, err := rdsSvc.StopDBInstance(&rds.StopDBInstanceInput{
			DBInstanceIdentifier: aws.String(instance),
		})
		if err != nil {
			fmt.Println(err)
			continue
		}
		fmt.Printf("Instance %s stopped:\n%+v", instance, out)
	}
}

func main() {
	lambda.Start(HandleRequest)
}
