provider "azurerm" {
  features {}
}

terraform { 
  backend "azurerm" {} 
}

module "ResourceGroup" {
  source = "../modules/ResourceGroup"
  location = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_kubernetes_cluster" "Test_WebApp" {
  name                = "Test_WebApp"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "testwebapp-dns"
  depends_on = [ module.ResourceGroup ]

  default_node_pool {
    name       = "linux"
    node_count = 1
    vm_size    = "Standard_B2s"
    os_sku     = "Ubuntu"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "test"
  }

  local_account_disabled = false

  network_profile {
    network_plugin     = "kubenet"
    dns_service_ip     = "10.0.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
    outbound_type      = "loadBalancer"
    pod_cidr           = "10.244.0.0/16"
    service_cidr       = "10.0.0.0/16"
    load_balancer_profile {
      managed_outbound_ip_count = 1
      idle_timeout_in_minutes   = 4
    }
  }
}