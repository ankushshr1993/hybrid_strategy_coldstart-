resource "null_resource" "copy_files" {
  provisioner "local-exec" {
    command     = <<-EOT
      scp -rp -i ${var.privatekey} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${path.module}/../scripts ${var.user}@${var.master_ip}:
      scp -rp -i ${var.privatekey} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${path.module}/../scripts ${var.user}@${var.worker_ip}:
  EOT
    interpreter = ["/bin/bash", "-c"]
  }
}

resource "null_resource" "ssh_setup_master_to_worker_step1" {
  provisioner "local-exec" {
    command     = <<-EOT
       ssh -i ${var.privatekey} -x -oStrictHostKeyChecking=no -tt ${var.user}@${var.master_ip} -P "mkdir -p \.ssh && cp scripts/docker_rsa \.ssh/id_rsa && cp scripts/docker_rsa.pub \.ssh/id_rsa.pub && chmod 400 \.ssh/id_rsa \.ssh/id_rsa.pub"
  EOT
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [ null_resource.copy_files ]
}

resource "null_resource" "ssh_setup_master_to_worker_step2" {
  provisioner "local-exec" {
    command     = <<-EOT
       ssh -i ${var.privatekey} -x -oStrictHostKeyChecking=no -tt ${var.user}@${var.worker_ip} -P "mkdir -p \.ssh && cp scripts/docker_rsa.pub \.ssh/authorized_keys && chmod 400 \.ssh/authorized_keys"
  EOT
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [ null_resource.copy_files, null_resource.ssh_setup_master_to_worker_step1 ]
}

resource "null_resource" "k8_master" {
  provisioner "local-exec" {
    command     = <<-EOT
       ssh -i ${var.privatekey} -x -oStrictHostKeyChecking=no -tt ${var.user}@${var.master_ip} -P "chmod -R 755 scripts && cd scripts && ./k8_master.sh"
  EOT
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [ null_resource.copy_files ]
}

resource "null_resource" "kubejoin_output_copy_to_worker_node" {
  provisioner "local-exec" {
    command     = <<-EOT
      scp -i ${var.privatekey} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.user}@${var.master_ip}:scripts/kubejoin_output ${path.module}/../scripts/
      scp -i ${var.privatekey} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${path.module}/../scripts/kubejoin_output ${var.user}@${var.worker_ip}:scripts/
      sleep 30
  EOT
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [ null_resource.copy_files, null_resource.k8_master ]
  
}

resource "null_resource" "k8_worker" {
  provisioner "local-exec" {
    command     = <<-EOT
       ssh -i ${var.privatekey} -x -oStrictHostKeyChecking=no -tt ${var.user}@${var.worker_ip} -P "cd scripts && ./k8_worker.sh"
  EOT
    interpreter = ["/bin/bash", "-c"]
  } 
  depends_on = [ null_resource.copy_files, null_resource.k8_master, null_resource.kubejoin_output_copy_to_worker_node ]
}

resource "null_resource" "k8_worker_join" {
  provisioner "local-exec" {
    command     = <<-EOT
       ssh -i ${var.privatekey} -x -oStrictHostKeyChecking=no -tt ${var.user}@${var.worker_ip} -P "cd scripts && chmod 755 kubejoin_output && sudo \$(cat kubejoin_output)"
  EOT
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [ null_resource.copy_files, null_resource.k8_master, null_resource.kubejoin_output_copy_to_worker_node ]
}

  resource "null_resource" "update_mycluster" {
    provisioner "local-exec" {
      command     = <<-EOT
        cp ${path.module}/../scripts/mycluster.yaml.template ${path.module}/../scripts/mycluster.yaml
        sed -i "s/CLUSTER_IP/${var.master_ip}/g" ${path.module}/../scripts/mycluster.yaml
        scp -i ${var.privatekey} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${path.module}/../scripts/mycluster.yaml ${var.user}@${var.master_ip}:scripts/
        sleep 5 
      EOT
      interpreter = ["/bin/bash", "-c"]
    }
    depends_on = [ null_resource.copy_files, null_resource.k8_master, null_resource.kubejoin_output_copy_to_worker_node, null_resource.k8_worker ]
  }

  resource "null_resource" "update_openwhisk" {
    provisioner "local-exec" {
      command     = <<-EOT
        cp ${path.module}/../scripts/openwhisk.sh.template ${path.module}/../scripts/openwhisk.sh
        sed -i "s/PUBLIC_IP/${var.master_ip}/g" ${path.module}/../scripts/openwhisk.sh
        scp -i ${var.privatekey} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${path.module}/../scripts/openwhisk.sh ${var.user}@${var.master_ip}:scripts/
        sleep 5 
      EOT
      interpreter = ["/bin/bash", "-c"]
    }
    depends_on = [ null_resource.copy_files, null_resource.k8_master, null_resource.kubejoin_output_copy_to_worker_node, null_resource.k8_worker ]
  }

resource "null_resource" "openwhisk" {
  provisioner "local-exec" {
    command     = <<-EOT
       ssh -i ${var.privatekey} -x -oStrictHostKeyChecking=no -tt ${var.user}@${var.master_ip} -P "cd scripts && ./openwhisk.sh"
  EOT
    interpreter = ["/bin/bash", "-c"]
  } 
  depends_on = [ null_resource.copy_files, null_resource.k8_master, null_resource.kubejoin_output_copy_to_worker_node, null_resource.k8_worker, null_resource.openwhisk ]
}

##resource "null_resource" "openfaas" {
##  provisioner "local-exec" {
##    command     = <<-EOT
##       ssh -i ${var.privatekey} -x -oStrictHostKeyChecking=no -tt ${var.user}@${var.master_ip} -P "chmod 755 openfaas.sh && ./openfaas.sh"
##  EOT
##    interpreter = ["/bin/bash", "-c"]
##  } 
##  depends_on = [ null_resource.copy_files, null_resource.k8_master, null_resource.kubejoin_output_copy_to_worker_node, null_resource.k8_worker, null_resource.openwhisk, null_resource.openwhisk ]
##}
