class Puppet::Provider::Mountpoint < Puppet::Provider
  def exists?
    Puppet.debug("Mountpoint checking for entry[:name] existence: #{entry[:name]}")
    ! entry[:name].nil?
  end

  def create
    mount_with_options(resource[:device], resource[:name])
  end

  def destroy
    unmount(resource[:name])
  end

  def device
    entry[:device]
  end

  def device=(value)
    unmount(resource[:name])
    mount_with_options(resource[:device], resource[:name])
  end

  def refresh
    Puppet.debug("Mountpoint received refresh for #{entry[:name]}")
    remount if resource[:ensure] == :present and exists?
  end

  private

  def mount_with_options(*args)
    options = []
    if resource[:options] && resource[:options] != :absent
      options << '-o'
      options << (resource[:options].is_a?(Array) ?  resource[:options].join(',') : resource[:options])
    end

    mount(*(options + args.compact))
  end

  def entry
    raise Puppet::DevError, "Mountpoint entry method must be overridden by the provider"
  end

  def remount
    if resource[:remounts] == :true
      Puppet.debug("Mountpoint attempting to remount #{resource[:name]}")
      mount_with_options "-o", "remount", resource[:name]
    else
      Puppet.debug("Mountpoint attempting to unmount/mount #{resource[:name]}")
      unmount(resource[:name])
      mount_with_options(resource[:device], resource[:name])
    end
  end
end
