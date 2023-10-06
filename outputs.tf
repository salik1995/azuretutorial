output "student_names" {
  value = [for student in local.student_names: student]
}

output "listofwindowsapp:
 { 
  value = [for windows in local.student_names: student]
  }

