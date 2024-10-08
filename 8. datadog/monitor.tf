# monitor.tf
resource "datadog_monitor" "process_alert_example" {
  name    = "Process Alert Monitor"
  type    = "process alert"
  message = "Multiple Java processes running on example-tag"
  query   = "processes('java').over('example-tag').rollup('count').last('10m') > 1"
  monitor_thresholds {
    critical          = 1.0
    critical_recovery = 0.0
  }

  notify_no_data    = false
  renotify_interval = 60
}

resource "datadog_monitor" "foo" {
  name    = "Name for monitor foo"
  type    = "metric alert"
  message = "Monitor triggered. Notify: @hipchat-channel"
  query   = "avg(last_1h):avg:aws.ec2.cpu{environment:foo,host:foo} by {host} > 2"
  monitor_thresholds {
    ok       = 0
    warning  = 1
    critical = 2
  }
  timeout_h    = 24
  include_tags = true
  #silenced {
  #  "*" = 0
  # }
  tags = ["foo:bar", "baz"]
}

# Create a new Datadog - Amazon Web Services integration
resource "datadog_integration_aws" "sandbox" {
  account_id                 = data.aws_caller_identity.current.account_id
  role_name                  = "DatadogIntegrationRole"
  metrics_collection_enabled = "true"
  filter_tags                = ["Name:Ansible-Ubuntu"]
  host_tags                  = ["Name:Ansible-Ubuntu"]
  account_specific_namespace_rules = {
    auto_scaling = false
    opsworks     = false
  }
}

resource "datadog_monitor" "cpuMonitor1" {
  name    = "cpu monitor"
  type    = "metric alert"
  message = "CPU usage alert"
  query   = "avg(last_1m):avg:system.cpu.system{*} by {host} > 60"
}

resource "datadog_monitor" "demo" {
  name               = "Kubernetes Pod Health"
  type               = "metric alert"
  message            = "Kubernetes Pods are not in an optimal health state. Notify: @operator"
  escalation_message = "Please investigate the Kubernetes Pods, @operator"
  priority           = 1

  query = "max(last_1m):sum:kubernetes.containers.running{short_image:demo} <= 1"

  monitor_thresholds {
    ok       = 3
    warning  = 2
    critical = 1
  }

  notify_no_data = true

  tags = ["app:demo", "env:demo"]
}

resource "datadog_monitor" "ec2" {
  name              = "Terraform Example Monitor"
  type              = "metric alert"
  query             = "avg(last_1h):avg:aws.ec2.cpu{env:prod} by {host} > 4"
  message           = "CPU utilization is above 4."
  tags              = ["env:prod"]
  notify_no_data    = true
  no_data_timeframe = 2
  priority          = 2

  require_full_window = true

  # Define notifications
  monitor_thresholds {
    critical          = "4"
    warning           = "3"
    warning_recovery  = "2.5"
    critical_recovery = "2"
  }
}