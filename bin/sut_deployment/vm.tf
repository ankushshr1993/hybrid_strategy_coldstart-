module "virtual_machine_master" {
  source                   = "./compute-vm"
  project_id               = "coldstart-345610"
  region                   = "europe-west3"
  zone                     = "europe-west3-a"
  name                     = "master-automation"
  instance_type            = "e2-standard-2"
  user                     = "ankush_sharma_job_gmail_com"
  network_interfaces = [
    {
      network              = "default"                                                                                     # virtual network name or self_link
      subnetwork           = "projects/coldstart-345610/regions/europe-west3/subnetworks/default"
      #subnetwork           = "projects/coldstart-345610/regions/europe-west3/subnetworks/vnet-1-us-central1-subnet-1" # subnet name or self_link
      nat                  = true                                                                                         # nat is false external_ip is not assigned to vm. if true external_ip address is assigned to vm.
      addresses            = null                                                                                         # have two keys internal and external. internal = private_ip address external = public_ip address eg. mentioned below. If set to null they will be auto assigned. external_ip is only assigned if nat is true. 
    }
  ]

  # attached_disks           = [
  #                             {
  #                               name                 = "master-node-disk"
  #                               source               = "master-node-disk"
  #                               options              = {
  #                                                       mode               = null
  #                                                      } 
  #                             }
  #                            ]

  boot_disk                = {
                              image                  = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2004-lts"
                              type                   = "pd-balanced"
                              size                   = 60
                             }
}

module "virtual_machine_worker" {
  source                   = "./compute-vm"
  project_id               = "coldstart-345610"
  region                   = "europe-west3"
  zone                     = "europe-west3-a"
  name                     = "worker-automation"
  instance_type            = "e2-standard-2"
  user                     = "ankush_sharma_job_gmail_com"
  network_interfaces       = [
                                {
                                  network    = "default"                      # virtual network name or self_link
                                  subnetwork = "projects/coldstart-345610/regions/europe-west3/subnetworks/default"
                                  #subnetwork = "projects/capable-alcove-346110/regions/us-central1/subnetworks/vnet-1-us-central1-subnet-1" # subnet name or self_link
                                  nat        = true                          # nat is false external_ip is not assigned to vm. if true external_ip address is assigned to vm.
                                  addresses  = null                          # have two keys internal and external. internal = private_ip address external = public_ip address eg. mentioned below. If set to null they will be auto assigned. external_ip is only assigned if nat is true. 
                                }
                              ]
  
  
  # attached_disks           = [
  #                              {
  #                                name = "worker-node-disk"
  #                                  source = "worker-node-disk"
  #                                options = {
  #                                  mode = null
  #                                }
  #                              }
  #                            ]
 
  boot_disk                = {
                              image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2004-lts"
                              type  = "pd-balanced"
                              size  = 60
                             }
}

module "kubernetes_install" {
  count                         = 1
  source                        = "./install-kubernetes"
  user                          = "ankush_sharma_job_gmail_com"
  master_ip                     = module.virtual_machine_master.external_ip
  worker_ip                     = module.virtual_machine_worker.external_ip
  depends_on = [ module.virtual_machine_master, module.virtual_machine_worker ]
}

