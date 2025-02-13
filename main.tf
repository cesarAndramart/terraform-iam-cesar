provider "aws" {
    region = "us-east-1"
}

#Creación de la política para permitir listado y creación de lambdas
resource "aws_iam_policy" "lambda_policy" {
    name = "LambdaListCreatePolicy_cesar"
    description = "Política que permite listar y crear lambdas"

    policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "lambda:ListFunctions",
          "lambda:CreateFunction"
        ]
        Resource = "*"
      }
    ]
  }
    )
}

#Creación de un grupo IAM para aplicar la política
resource "aws_iam_group" "lambda_group_cesar" {
    name = "LambdaGroup-cesar"
}

#Attachment de la política creada
resource "aws_iam_group_policy_attachment" "lambda_policy_attachment" {
    group = aws_iam_group.lambda_group_cesar.name
    policy_arn = aws_iam_policy.lambda_policy.arn
}

# Creación de un usuario de iam
resource "aws_iam_user" "user_1_lambda_cesar" {
    name = "user_1_lambda_cesar"
}
#Attachment del usuario al grupo creado
resource "aws_iam_user_group_membership" "user_group_membership" {
    user = aws_iam_user.user_1_lambda_cesar.name
    groups = [aws_iam_group.lambda_group_cesar.name]
}
## Definición de los outputs
output "lambda_policy_arn" {
  value       = aws_iam_policy.lambda_policy.arn
  description = "La ARN de la política personalizada para Lambda"
}

output "lambda_group_name" {
  value       = aws_iam_group.lambda_group_cesar.name
  description = "El nombre del grupo de IAM creado para acceso a Lambda"
}