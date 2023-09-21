variable "client_id" {
  type=string
}

variable "client_secret" {
  type=string
}

variable "subscription_id" {
  type=string
}

variable "tenant_id" {
  type=string
}

variable "prefix" {
  type=string
  default="class56"
}

variable "env" {
  type=string
  default="dev"
}

variable "storage" {
  type=string
  default="Standard"
}

variable "no_hardcoded" {
  type=string
  default="private"
}
