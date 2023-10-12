variable "ipv4_cidr" {
    type=string
    description = "ipv4 cidr block"
}
variable "namespace" {
    type=string
    description = "namespace"
}
variable "stage" {
    type=string
    description = "stage"
}
variable "sn1_ipv4_cidr" {
    type=string
    description = "ipv4 cidr block"
    default = "192.168.1.0/24"
}
variable "sn2_ipv4_cidr" {
    type=string
    description = "ipv4 cidr block"
    default = "192.168.2.0/24"
}
variable "sn3_ipv4_cidr" {
    type=string
    description = "ipv4 cidr block"
    default = "192.168.3.0/24"
}