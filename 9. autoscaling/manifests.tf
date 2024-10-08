resource "kubectl_manifest" "cluster_role" {

  for_each           = data.kubectl_file_documents.cluster_role.manifests
  yaml_body          = each.value
}

resource "kubectl_manifest" "cluster_role_binding" {
  depends_on = [
    kubectl_manifest.cluster_role,
  ]
  for_each           = data.kubectl_file_documents.cluster_role_binding.manifests
  yaml_body          = each.value
}

resource "kubectl_manifest" "role" {

  for_each           = data.kubectl_file_documents.role.manifests
  yaml_body          = each.value
  override_namespace = "kube-system"
}

resource "kubectl_manifest" "role_binding" {
  depends_on = [
    kubectl_manifest.role,
  ]
  for_each           = data.kubectl_file_documents.role_binding.manifests
  yaml_body          = each.value
  override_namespace = "kube-system"
}

resource "kubectl_manifest" "auto_scaler" {
  depends_on = [
    kubectl_manifest.sa,
  ]
  for_each           = data.kubectl_file_documents.autoscaler.manifests
  yaml_body          = each.value
  override_namespace = "kube-system"
}

resource "kubectl_manifest" "sa" {
  depends_on = [
    kubectl_manifest.role_binding,
  ]
  for_each           = data.kubectl_file_documents.svc.manifests
  yaml_body          = each.value
  override_namespace = "kube-system"
}