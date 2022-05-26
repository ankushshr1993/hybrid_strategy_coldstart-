# hybrid_strategy_coldstart

<!-- BEGIN TFDOC -->
To run the tool, the user needs to first clone our repository on GitHub and then open the repository. On executing the prerequisites.sh script, the user has the environment ready for running OptiBench. The next step is to set the value of parameters in the vm.tf (module file) where you add/modify variables. The user executes the tool by navigating to the SUT\_deployment folder and executing the main script using terraform commands. It is the most important script in this tool and is responsible for build the complete infrastrcuture with all the VMs, kubernetes cluster,secret keys etc. Then go to script folder on master node and execute shell script manage.sh with 3 flags.
\textbf{./managed.sh [Type of function] [Type of invocation] [No of invocations]
}
<!-- END TFDOC -->
Where Type of function will be the 5 function with which we have tested ,Type of invocation can be series or parallel and number of invocation will the number of function that you would like to trigger and .if you will enter ./managed.sh.The output will display all the options for experiments.


# Google Compute Engine VM module with Kubernetes , Openwhisk and Openfaas platforms 

This module will create 2 Virtual machines on GCP , install kubernetes cluster ,helm , Openwhisk and Openfaas platforms
## Pre-requisites
* VM to execute the terrafrom code, with terraform installed.
* Service account attached to terraform VM for access to create resources in azure portal
* Virtual network
* Subnet 
* Project id
* public/private key pair which you want to be attached to master and worker node.
* Additional disks created if you want to atach it to VM.
* If you want give your own public/private key pair , generate it and replace your publickey with the gcloud_instance , gcloud_instance.pub keys already present in the automation folder.
* If you want to provide custom publickey name . Pass the attribute publickey="<mypublickey>" to the module.
* Public/private key should be of the user provided as attribute to the vm module.

## What you will get.
* 2 child modules are executed.
  * Module1 - virtual machine
  * Moudle2 - install kubernetes , openwhisk and openfaas.
* public key will be attached to the VMs.
* Firewall rules will be created and attached the VNET. Please check default firewall ports in the table below. If you want to customize it , you will have to give new ports with the existing default ports in the module attributes.(if you provide ports explicitly only ports provided in the attribute will be added and not the default ports.)
* Mandatory and optional attributes are provided in the "Variables" table.

## References
Use below references for check details about GCP attributes used in the module.
* [GCP VM Module](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)
* [GCP firewall Module](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall)
* [GCP null resource](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource)

## Default variables modification
* Update below files for default value modifications.
* compute-vm/variables.tf
* install-kubernetes/variables.tf

## Examples

### Instance using defaults

The simplest example leverages defaults for the boot disk image and size.
Check table in the page below to find mandaory parameters
  

**vm.tf  (module file where you add/modify variables)**  
```hcl
module "virtual_machine_master" {
  source                        = "./compute-vm"                                 # Source module path
  project_id                    = "capable-alcove-346110"                        # project ID
  region                        = "us-central1"                                  
  zone                          = "us-central1-a"                            zone                          = "username"   
  name                          = "master-node"                                  # Provide machine name                    
  instance_type                 = "e2-standard-2"                                 
  network_interfaces            = [                                              
                                     {
                                       network    = "vnet-1"                     # virtual network name or self_link
                                       subnetwork = "projects/capable-alcove-346110/regions/us-central1/subnetworks/vnet-1-us-central1-subnet-1" # subnet self link
                                       nat        = true                         # nat is false external_ip is not assigned to vm. if true external_ip address is assigned to vm.
                                       addresses  = null                         # have two keys internal and external. internal = "private_ip address" external = "public_ip address" eg. mentioned below. If set to null they will be auto assigned. external_ip is only assigned if nat is true. 
                                       /*
                                           addresses  = {
                                               internal = "y.y.y.y"              # put null if you want it to be auto-assigned.
                                               external = "x.x.x.x"              # put null if you want it to be auto-assigned.
                                           }
                                       */
                                     }
                                   ]


  attached_disks                 = [                                             # [Optional] Attach disks to the VM , they should be already exist. This module doesnt create new disk.                                            
                                     {             
                                       name        = "terraformvm-demo-disk"              # name of the disk to be attached.                          
                                       source      = "terraformvm-demo-disk"              # name or self link of the disk to be attached.
                                       options     = {
                                         mode = null                                      # 2 modes READ_WRITE or READ_ONLY . default is READ_WRITE
                                       }
                                     }
                                   ]

  boot_disk                       = {
                                     image   = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2004-lts"      # image self link
                                               #projects/{project}/global/images/family/{family}   self link format for reference
                                     type    = "pd-balanced"                                                        # The GCE disk type. May be set to pd-standard, pd-balanced or pd-ssd
                                     size    = 60
                                   }

}
module "virtual_machine_worker" {
  source               = "./compute-vm"
  project_id           = "capable-alcove-346110"
  region               = "us-central1"
  zone                 = "us-central1-c"
  name                 = "master-node"
  instance_type        = "e2-standard-2"
  network_interfaces   = [
    {
      network    = "vnet-1"                                                                                
      subnetwork = "projects/capable-alcove-346110/regions/us-central1/subnetworks/vnet-1-us-central1-subnet-1" 
      nat        = true                                                                              
      addresses  = null 
    }
  ]

  attached_disks = [
    {
      name        = "terraformvm-demo-disk"
      source      = "terraformvm-demo-disk"
      options     = {
        mode      = null
      }
    }
  ]

  boot_disk = {
    image   = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2004-lts"
    type    = "pd-balanced"
    size    = 60
  }
}

module "3rdparty_install" {                                                                               # Module to install Kubernetes,Openfaas and OpenWhisk
  count                         = 1
  source                        = "./install-kubernetes"
  user                          = "username"                                                            # public key for this user will be added to VM and will be used to login 
  master_ip                     = module.virtual_machine_master.external_ip                               # change name of module.<moudle_name here eg.virtual_machine_master > if you change module names above. 
  worker_ip                     = module.virtual_machine_worker.external_ip                               # change name of module.<moudle_name here eg.virtual_machine_worker > if you change module names above. 
  depends_on -                  = [ module.virtual_machine_master, module.virtual_machine_worker ]        # change name of module.<moudle_name> if you change module names above. 
}

```

<!-- BEGIN TFDOC -->

## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| project_id | Project id. | <code>string</code> | ✓ |  |
| region | Compute region. | <code>string</code> | ✓ |  |
| zone | Compute zone. | <code>string</code> | ✓ |  |
| name | Instance name. | <code>string</code> | ✓ |  |
| user | username which will be used to login to vm. | <code>string</code> |✓  |  |
| description | Description of a Compute Instance. | <code>string</code> |  | <code>&#34;Managed by the compute-vm Terraform module.&#34;</code> |
| instance_type | Instance type. | <code>string</code> |  | <code>&#34;e2-standard-2&#34;</code> |
| hostname | Instance FQDN name. | <code>string</code> |  | <code>null</code> |
| labels | Instance labels. | <code>map&#40;string&#41;</code> |  | <code>&#123;&#125;</code> |
| network_interfaces | Network interfaces configuration. Use self links for Shared VPC, set addresses to null if not needed. | <code title="list&#40;object&#40;&#123;&#10;  nat        &#61; bool&#10;  network    &#61; string&#10;  subnetwork &#61; string&#10;  addresses &#61; object&#40;&#123;&#10;    internal &#61; string&#10;    external &#61; string&#10;  &#125;&#41;&#10;&#125;&#41;&#41;">list&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> | ✓ |  |
| attached_disks| Additional disks, if options is null defaults will be used in its place. Source type is one of 'image' (zonal disks in vms and template), 'snapshot' (vm), 'existing', and null. | <code title="list&#40;object&#40;&#123;&#10;  name        &#61; string&#10;  source      &#61; string&#10;  options &#61; object&#40;&#123;&#10;    mode         &#61; string&#10;  &#125;&#41;&#10;&#125;&#41;&#41;">list&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123; mode = "READ_WRITE"&#125;</code> |
| firewall_rules | Firewall rules to be added to vnet | <code title="object&#40;&#123;&#10;  source_ranges &#61; list&#40;string&#41;&#10;  target_tags  &#61; list&#40;string&#41;&#10;  protocol  &#61; string&#10;&#125;&#41;&#10;  target_tags  &#61; list&#40;string&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code title="&#123;&#10;  source_ranges &#61; [0.0.0.0/0"]&#10;  target_tags  &#61; []&#10;  protocol  &#61; &#34;tcp,icmp&#34;&#10;  ports  &#61; ["22","6443","2379-2380","10250-10252","10257","10259","30000-32767","8080","443","80"]&#10;&#125;">&#123;&#8230;&#125;</code> |
| boot_disk | Boot disk properties. | <code title="object&#40;&#123;&#10;  image &#61; string&#10;  size  &#61; number&#10;  type  &#61; string&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code title="&#123;&#10;  image &#61; &#34;projects&#47;ubuntu-os-cloud&#47;global&#47;images&#47;family&#47;ubuntu-2004-lts&#34;&#10;  type  &#61; &#34;pd-balanced&#34;&#10;  size  &#61; 10&#10;&#125;">&#123;&#8230;&#125;</code> |
| boot_disk_delete | Auto delete boot disk. | <code>bool</code> |  | <code>true</code> |
| can_ip_forward | Enable IP forwarding. | <code>bool</code> |  | <code>false</code> |
| confidential_compute | Enable Confidential Compute for these instances. | <code>bool</code> |  | <code>false</code> |
| enable_display | Enable virtual display on the instances. | <code>bool</code> |  | <code>false</code> |
| encryption | Encryption options. Only one of kms_key_self_link and disk_encryption_key_raw may be set. If needed, you can specify to encrypt or not the boot disk. | <code title="object&#40;&#123;&#10;  disk_encryption_key_raw &#61; string&#10;  kms_key_self_link       &#61; string&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code>null</code> |
| min_cpu_platform | Minimum CPU platform. | <code>string</code> |  | <code>null</code> |
| network_interface_options | Network interfaces extended options. The key is the index of the inteface to configure. The value is an object with alias_ips and nic_type. Set alias_ips or nic_type to null if you need only one of them. | <code title="map&#40;object&#40;&#123;&#10;  alias_ips &#61; map&#40;string&#41;&#10;  nic_type  &#61; string&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| options | Instance options. | <code title="object&#40;&#123;&#10;  allow_stopping_for_update &#61; bool&#10;  deletion_protection       &#61; bool&#10;  preemptible               &#61; bool&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code title="&#123;&#10;  allow_stopping_for_update &#61; true&#10;  deletion_protection       &#61; false&#10;  preemptible               &#61; false&#10;&#125;">&#123;&#8230;&#125;</code> |
| scratch_disks | Scratch disks configuration. | <code title="object&#40;&#123;&#10;  count     &#61; number&#10;  interface &#61; string&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code title="&#123;&#10;  count     &#61; 0&#10;  interface &#61; &#34;NVME&#34;&#10;&#125;">&#123;&#8230;&#125;</code> |
| service_account_email | Service account email. Unused if service account is auto-created. | <code>string</code> |  | <code>null</code> |
| service_account_scopes | Scopes applied to service account. | <code>list&#40;string&#41;</code> |  | <code>&#91;"userinfo-email", "compute-ro", "storage-ro"&#93;</code> |
| shielded_config | Shielded VM configuration of the instances. | <code title="object&#40;&#123;&#10;  enable_secure_boot          &#61; bool&#10;  enable_vtpm                 &#61; bool&#10;  enable_integrity_monitoring &#61; bool&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code>null</code> |
| publickey | public ssh key which will be attached to vm , is should be of the username you provide for user variable | <code>string</code> |  | gcloud_instance.pub |
| tags | Instance network tags for firewall rule targets. | <code>list&#40;string&#41;</code> |  | <code>&#91;"http-server","https-server"&#93;</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| vm_master_ip | Master virtual machine IP addresses. |  |
| vm_worker_ip | Wroker virtual machine IP addresses. |  |

<!-- END TFDOC -->

