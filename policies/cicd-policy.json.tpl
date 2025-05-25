{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Statement1",
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "lambda:*",
                "apigateway:*",
                "iam:*",
                "ec2:*",
                "cloudfront:*"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:SourceVpc": "${vpc}"
                }
            }
        },
        {
            "Sid": "Statement2",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:ListAllMyBuckets",
                "s3:GetBucketPolicy",
                "s3:GetBucketPolicyStatus",
                "lambda:ListFunctions",
                "lambda:GetFunction",
                "lambda:GetPolicy",
                "lambda:GetFunctionConfiguration",
                "ec2:Describe*",
                "cloudfront:GetDistribution",
                "cloudfront:ListDistributions"

            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "Statement3",
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": [
                        "lambda.amazonaws.com",
                        "codebuild.amazonaws.com"
                    ],
                    "aws:SourceVpc": "${vpc}"
                },
                "ArnLike": {
                    "iam:AssociatedResourceARN": [
                        "arn:aws:lambda:*:${account_id}:function:*",
                        "arn:aws:codebuild:*:${account_id}:project/*"
                    ]
                }
            }
        }
    ]
}
