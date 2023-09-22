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

variable "system" {
  type=string
  default="private"
}

variable "numeric" {
  type=number
  default="private"
}

variable "Standard_D2_v2" {
  type=string
  default="private"
}

variable "exampleaks1" {
  type=string
  default="private"
}
