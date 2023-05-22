# bicep-demo

## Prereqs
- Git repo
- VSCode extensions (Bicep + Azure Account)
- Azure subscription

<br>

## Main template
- mkdir bicep + touch main.bicep
  - Intellisense (space på ny rad)
- resource rg (keyword, symboliskt namn, resurstyp, API-version, requiredProperties)
- targetScope (default RG, ändra till subscription)
- param location (string + defaultValue deployment().location)
- Deploy Bicep file

<br>

- var prefix (bicep-demo)
- param tags (object + empty defaultValue)
- Generate Parameters File (tags environment)
- Deploy Bicep file

<br>

- main.bicep: resource vnet (incorrect scope - modules/nested deployments måste användas för att deploya till ett annat scope)

<br>

## Modules
- mkdir modules + touch vnet.bicep (ingen syntax-skillnad på main-fil VS modul-filer, bara en fråga om hur man kallar på filen)
- Move resource vnet to vnet.bicep
- targetScope (default RG)
- param name (inget defaultValue)
- param location (inget defaultValue)
- param tag (defaultValue från rg)
- param x2 addressPrefixes (inget defaultValue)

<br>

- module keyword (main.bicep)
- module scope (symbolic ref rg)
- module params (name + location + addressPrefixes - tags endast om mot förmodan vill overrida default)
- Deploy Bicep file

<br>

## Loops
- properties.subnets (hårdkoda först, därefter property loop)
- cidrSubnet()
- module param subnets (array + empty defaultValue)
- subnet object (name + size)
- module output addressPrefixes - toObject()
- main output addressPrefixes - vnet.outputs

<br>

- resource nsg (resource loop)
- name, location, tags
- Lägg till nsg.id på subnets.properties
- Deploy Bicep file

<br>

## Conditions
- Ta bort NSGs (Bicep har ej livscykelhantering)
- Lägg till conditional x2 subnet.rules - contains()
- Lägg till tom array rules på snet-frontend (NSG skapas då upp med default-regler)
- Deploy Bicep file

- Lägg till properties.securityRules + tom array rules på snet-backend + specifik rule på snet-frontend:
  - allow-inbound-https (source: service tag Internet + destination: param addressPrefix)
- Deploy Bicep file

- vnet.bicep: Lägg till default implicit deny - union()
- Deploy Bicep file

<br>

## Multiple environments (single param file)
- Ta bort RG
- Lägg till param environment
- Lägg till param decorator allowed (dev + prod)
- Ändra var prefix (string interpolation environment)
- Ändra param tags till var och ta bort ur parameterfil
- Ändra param addressPrefix till object och uppdatera parameterfil
- Ändra till addressPrefix[environment] x2
- Deploy Bicep file (dev)
- Deploy Bicep file (prod)

<br>

## Automation (Azure CLI)
- az logout
- az login
- az account set -s 9b184a26-7fff-49ed-9230-d11d484ad51b
- az deployment sub validate --location westeurope --template-file main.bicep --parameters main.parameters.json
- az deployment sub what-if --location westeurope --template-file main.bicep --parameters main.parameters.json
- az deployment sub create --location westeurope --template-file main.bicep --parameters main.parameters.json

<br>

## Bicep param files (preview)
- touch main.bicepparam
- touch bicepconfig.json (paramsFiles true)
- using main.bicep
- param addressPrefix
- param environment (än så länge inte supporterat att skicka in params inline via CLI)
- mv main.bicepparam dev.bicepparam
- cp dev.bicepparam prod.bicepparam
- rm main.parameters.json
- Ändra param environment (dev + prod)
- Ändra addressPrefix till string (.bicepparam + main.bicep)
- az deployment sub create --location westeurope --template-file main.bicep --parameters dev.bicepparam
- az deployment sub create --location westeurope --template-file main.bicep --parameters prod.bicepparam