provider "azurerm" {
  features {}
}

# Defina as variáveis conforme necessário
variable "resource_group_name" {
  default = "nome-do-seu-resource-group"
}

variable "webapp_name" {
  default = "nome-do-seu-webapp"
}

variable "vnet_name" {
  default = "nome-da-sua-vnet"
}

variable "subnet_name" {
  default = "nome-da-sua-subnet"
}

resource "azurerm_app_service_plan" "example" {
  name                = "${var.webapp_name}-appserviceplan"
  location            = "nome-da-sua-localizacao"
  resource_group_name = var.resource_group_name
  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "example" {
  name                = var.webapp_name
  location            = "nome-da-sua-localizacao"
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.example.id

  site_config {
    # Configurações específicas do aplicativo, como linguagem, framework, etc.
  }

  app_settings = {
    # Configurações do aplicativo, se necessário
  }

  connection_string {
    type  = "SQLServer"
    name  = "MyDBConnection"
    value = "Server=tcp:myserver.database.windows.net;Database=mydatabase;"
  }

  depends_on = [azurerm_app_service_plan.example]
}

data "azurerm_virtual_network" "example" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "example" {
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.example.name
  resource_group_name  = var.resource_group_name
}

resource "azurerm_networking_subnet_route_table_association" "example" {
  subnet_id          = data.azurerm_subnet.example.id
  route_table_id     = "id-da-sua-tabela-de-roteamento"
}

resource "azurerm_app_service_virtual_network_swift_connection" "example" {
  app_service_id = azurerm_app_service.example.id
  vnet_id        = data.azurerm_subnet.example.id
}
