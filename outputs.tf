output "student_names" {
  value = [for student in local.student_names: student]
}
