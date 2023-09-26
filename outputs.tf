output "student_names" {
  value = [for student in locals.student_names: student]
}
