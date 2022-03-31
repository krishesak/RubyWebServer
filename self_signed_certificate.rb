require 'openssl'

class CertificateGenerator

	attr_reader :signed_cert
  
	def initialize
		genearte_ca_certifiate
		create_signing_request
		sign_certificate_by_ca
	end

  # Creates Certificate Authority certificate
	def genearte_ca_certifiate
		@ca_key = OpenSSL::PKey::RSA.new 2048
		cipher = OpenSSL::Cipher::Cipher.new 'AES-256-CBC'

		open 'ca_key.pem', 'w' do |f|
		  f.write @ca_key.export
		end
		
		ca_name = OpenSSL::X509::Name.parse 'CN=ca/DC=example'
		ca_certificate = OpenSSL::X509::Certificate.new
		ca_certificate.not_before = Time.now
		ca_certificate.not_after = Time.now + 365 * 24 * 60 * 60
		ca_certificate.subject = ca_name
		ca_certificate.public_key = @ca_key.public_key
		ca_certificate.version = 2

		ef = OpenSSL::X509::ExtensionFactory.new
		ef.subject_certificate = ca_certificate
		ef.issuer_certificate = ca_certificate

		ca_certificate.add_extension ef.create_extension("subjectKeyIdentifier", "hash")
		ca_certificate.add_extension ef.create_extension("basicConstraints","CA:TRUE", true)
		ca_certificate.add_extension ef.create_extension("keyUsage", "cRLSign,keyCertSign", true)
		#Signing a certificate
		ca_certificate.issuer = ca_name
		ca_certificate.sign @ca_key, OpenSSL::Digest::SHA256.new
		@ca_certificate = ca_certificate
		open 'ca_certificate.pem', 'w' do |f|
			f.write ca_certificate.to_pem
		end
	end

  # Create sigining request to CA
	def create_signing_request
		@key = OpenSSL::PKey::RSA.new 2048
		subject = OpenSSL::X509::Name.parse 'CN=nobody/DC=example'
		csr = OpenSSL::X509::Request.new
		csr.version = 0
		csr.subject = subject
		csr.public_key = @key.public_key
		csr.sign @key, OpenSSL::Digest::SHA256.new
		open 'sign_request.pem', 'w' do |f|
		  f.write csr.to_pem
		end
	end
  
  # CA verifies and signing it
	def sign_certificate_by_ca
		csr = OpenSSL::X509::Request.new(File.read 'sign_request.pem')
		raise 'CSR can not be verified' unless csr.verify csr.public_key

		signed_cert = OpenSSL::X509::Certificate.new
		signed_cert.not_before = Time.now
		signed_cert.not_after = Time.now + 600
		signed_cert.version = 2

		signed_cert.subject = csr.subject
		signed_cert.public_key = csr.public_key
		signed_cert.issuer = @ca_certificate.subject

		extension_factory = OpenSSL::X509::ExtensionFactory.new
		extension_factory.subject_certificate = signed_cert
		extension_factory.issuer_certificate = @ca_certificate

		signed_cert.add_extension extension_factory.create_extension('basicConstraints', 'CA:FALSE')
		signed_cert.add_extension extension_factory.create_extension('keyUsage', 'keyEncipherment,dataEncipherment,digitalSignature')
		signed_cert.add_extension    extension_factory.create_extension('subjectKeyIdentifier', 'hash')

		signed_cert.sign @ca_key, OpenSSL::Digest::SHA256.new
		@signed_cert = signed_cert

		open 'signed_certificate.pem', 'w' do |f|
		  f.write signed_cert.to_pem
		end
	end

  def private_key
  	@key
  end

end
