# frozen_string_literal: true

require 'pathname'
require_relative '../log_performance/performance_times_logging/log_performance_times'

def correct_platform_name(agent)
  if agent['platform'].include?('aix')
    agent.to_s.split('-')[0].sub(/aix(\d)(\d)/, 'aix-\1.\2') + '-power'
  elsif agent.has_key?('template') && agent['template'].include?('fips')
    agent['template']
  else
    agent['platform']
  end
end

def run_statistax(agent, home_dir, is_gem)
  content = ::File.read(File.join(Pathname.new(File.expand_path('..', __dir__)), 'config.json'))
  create_remote_file(agent, "#{home_dir}/config.json", content)
  if agent['platform'] =~ /windows/
    puppetbin_path = '"/cygdrive/c/Program Files (x86)/Puppet Labs/Puppet/puppet/bin":"/cygdrive/c/Program Files/Puppet Labs/Puppet/puppet/bin"'
    on agent, %( echo 'export PATH=$PATH:#{puppetbin_path}' > /etc/bash.bashrc )
    on agent, "statistax.bat config.json #{is_gem}"
  else
    on agent, "statistax #{home_dir}/config.json #{is_gem}"
  end
end

def save_output(agent, home_dir, host_dir, is_gem)
  out_dir = File.join(host_dir, is_gem ? 'gem' : 'cpp')

  FileUtils.mkdir_p(out_dir)
  scp_from agent, "#{home_dir}/log/output.json", out_dir
end

test_name 'Run facter statistax' do
  log_dir = File.join(File.expand_path('..', __dir__), "log_dir")

  agents.each do |agent|
    is_gem        = false
    home_dir      = on(agent, 'pwd').stdout.chop
    platform_name = correct_platform_name(agent)
    host_dir      = File.join(log_dir, "#{platform_name}")

    step 'Run facter statistax for Cfacter' do
      run_statistax(agent, home_dir, is_gem)
    end

    step 'Save output' do
      save_output(agent, home_dir, host_dir, is_gem)
    end

    step 'Run facter statistax for facter-ng' do
      is_gem = 'true'
      run_statistax(agent, home_dir, is_gem)
    end

    step 'Save output to files' do
      save_output(agent, home_dir, host_dir, is_gem)
    end

    step 'Copy results to Google spreadsheet' do
      LogPerformanceTimes.new(log_dir).populate_logs_for(platform_name)
    end
  end
end
