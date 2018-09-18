class << Resolv

  def use_google_dns
    remove_const :DefaultResolver
    const_set :DefaultResolver, self.new(
      [Resolv::Hosts.new, Resolv::DNS.new(nameserver: ['8.8.8.8', '205.251.192.211', '205.251.195.96', '205.251.198.119'], search: ['my.exotel.in', 'twilix.exotel.in'], ndots: 1)]
    )
  end

end

Resolv.use_google_dns
require 'resolv-replace'