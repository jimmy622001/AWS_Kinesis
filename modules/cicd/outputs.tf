output "codecommit_repository_name" {
  description = "Name of the CodeCommit repository"
  value       = aws_codecommit_repository.main.repository_name
}

output "codepipeline_name" {
  description = "Name of the CodePipeline"
  value       = aws_codepipeline.main.name
}

output "codebuild_project_name" {
  description = "Name of the CodeBuild project"
  value       = aws_codebuild_project.main.name
}
