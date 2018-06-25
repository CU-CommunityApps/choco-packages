These are the notes for the CodePipeline -> CodeBuild process for building choco packages. There currently is no automated/scripted creation of these components. The json components below can be used as templates for a new branch, but the OAuth / GitHub integration must still be manually configured for the "Source" stage of the resulting CodePipeline.

Each branch of the `CU-CommunityApps/choco-packages` gets it own CodePipeline pipeline, each sharing the same CodeBuild project. The CodePipeline name must be in form `codepipeline-choco-<branch_name>`, as the downstream CodeBuild step uses the CodePipeline name to determine the resulting s3 object key.

## CodePipeline
```
{
	"pipeline": {
		"roleArn": "arn:aws:iam::530735016655:role/AWS-CodePipeline-Service",
		"stages": [{
				"name": "Source",
				"actions": [{
					"inputArtifacts": [],
					"name": "SourceBranch",
					"actionTypeId": {
						"category": "Source",
						"owner": "ThirdParty",
						"version": "1",
						"provider": "GitHub"
					},
					"outputArtifacts": [{
						"name": "SourceOutput"
					}],
					"configuration": {
						"Owner": "CU-CommunityApps",
						"Repo": "choco-packages",
						"PollForSourceChanges": "true",
						"Branch": "<BRANCH_NAME>",
						"OAuthToken": "fix_me_in_the_console"
					},
					"runOrder": 1
				}]
			},
			{
				"name": "Build",
				"actions": [{
					"inputArtifacts": [{
						"name": "SourceOutput"
					}],
					"name": "BuildPackages",
					"actionTypeId": {
						"category": "Build",
						"owner": "AWS",
						"version": "1",
						"provider": "CodeBuild"
					},
					"outputArtifacts": [],
					"configuration": {
						"ProjectName": "ChocoBuild"
					},
					"runOrder": 1
				}]
			}
		],
		"artifactStore": {
			"type": "S3",
			"location": "cu-codepipeline-choco-packages-build"
		},
		"name": "codepipeline-choco-<BRANCH_NAME>",
		"version": 4
	}
}

```

## CodeBuild
```
$ aws codebuild batch-get-projects --names ChocoBuild --profile cornell-stream --region us-east-1

{
    "projectsNotFound": [],
    "projects": [
        {
            "name": "ChocoBuild",
            "serviceRole": "arn:aws:iam::530735016655:role/service-role/code-build-ChocoBuild-service-role",
            "tags": [],
            "artifacts": {
                "namespaceType": "NONE",
                "packaging": "NONE",
                "type": "CODEPIPELINE",
                "name": "ChocoBuild"
            },
            "lastModified": 1521471138.489,
            "timeoutInMinutes": 60,
            "created": 1521470050.528,
            "environment": {
                "computeType": "BUILD_GENERAL1_SMALL",
                "privilegedMode": false,
                "image": "aws/codebuild/python:3.5.2",
                "type": "LINUX_CONTAINER",
                "environmentVariables": []
            },
            "source": {
                "type": "CODEPIPELINE"
            },
            "encryptionKey": "arn:aws:kms:us-east-1:530735016655:alias/aws/s3",
            "arn": "arn:aws:codebuild:us-east-1:530735016655:project/ChocoBuild"
        }
    ]
}
```

## IAM
AWS-CodePipeline-Service
```
{
    "Statement": [
        {
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketVersioning"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::codepipeline*",
                "arn:aws:s3:::elasticbeanstalk*"
            ],
            "Effect": "Allow"
        },
        {
            "Action": [
                "codecommit:CancelUploadArchive",
                "codecommit:GetBranch",
                "codecommit:GetCommit",
                "codecommit:GetUploadArchiveStatus",
                "codecommit:UploadArchive"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codedeploy:CreateDeployment",
                "codedeploy:GetApplicationRevision",
                "codedeploy:GetDeployment",
                "codedeploy:GetDeploymentConfig",
                "codedeploy:RegisterApplicationRevision"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "elasticbeanstalk:*",
                "ec2:*",
                "elasticloadbalancing:*",
                "autoscaling:*",
                "cloudwatch:*",
                "s3:*",
                "sns:*",
                "cloudformation:*",
                "rds:*",
                "sqs:*",
                "ecs:*",
                "iam:PassRole"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "lambda:InvokeFunction",
                "lambda:ListFunctions"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "opsworks:CreateDeployment",
                "opsworks:DescribeApps",
                "opsworks:DescribeCommands",
                "opsworks:DescribeDeployments",
                "opsworks:DescribeInstances",
                "opsworks:DescribeStacks",
                "opsworks:UpdateApp",
                "opsworks:UpdateStack"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "cloudformation:CreateStack",
                "cloudformation:DeleteStack",
                "cloudformation:DescribeStacks",
                "cloudformation:UpdateStack",
                "cloudformation:CreateChangeSet",
                "cloudformation:DeleteChangeSet",
                "cloudformation:DescribeChangeSet",
                "cloudformation:ExecuteChangeSet",
                "cloudformation:SetStackPolicy",
                "cloudformation:ValidateTemplate",
                "iam:PassRole"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codebuild:BatchGetBuilds",
                "codebuild:StartBuild"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ],
    "Version": "2012-10-17"
}
```

service-role/code-build-ChocoBuild-service-role
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:logs:us-east-1:530735016655:log-group:/aws/codebuild/ChocoBuild",
                "arn:aws:logs:us-east-1:530735016655:log-group:/aws/codebuild/ChocoBuild:*"
            ],
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::codepipeline-us-east-1-*",
                "arn:aws:s3:::cu-codepipeline-choco-packages-build*",
                "arn:aws:s3:::cornellstream-prod-adminimages*"
            ],
            "Action": [
                "s3:*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameters"
            ],
            "Resource": "arn:aws:ssm:us-east-1:530735016655:parameter/CodeBuild/*"
        }
    ]
}
```
