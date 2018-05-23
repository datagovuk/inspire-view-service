require 'open-uri'
require 'nokogiri'

class HomeController < ApplicationController

  def index
    @apikey = ENV["OS_APIKEY"]
    render 'index'
  end

  def preview_proxy
    url = params[:url]
    throw(:abort) if url.nil?

    # TODO: We don't want to be an open relay. We must ensure this
    # request is coming from a page we served.

    url = correct_url(url)

    begin
      doc = Nokogiri::XML(open(url))
      render xml: doc
    rescue Exception => e
      render nothing: true, status: :bad_request
    end
  end

  def correct_url(url)
    # Some URLs are bad and need cleaning up such as
    # http://lasigpublic.nerc-lancaster.ac.uk/ArcGIS/services/Biodiversity/GMFarmEvaluation/MapServer/WMSServer?request=GetCapabilities&service=WMS

    uri = Addressable::URI.parse(url)
    args = uri.query_values.map { |k, v|
      [k.downcase, v]
    }.to_h

    args['request'] = 'GetCapabilities' if args['request'].nil?
    args['service'] = 'WMS' if args['service'].nil?

    if !['wms', 'WMS'].include? args['service']
      raise 'Invalid value for "service"'
    end

    if !['getcapabilities', 'getfeatureinfo'].include? args['request'].downcase
      raise 'Invalid value for "request"'
    end

    uri.query_values = args
    return uri.to_s
  end

  def preview_getinfo
    # This is a proxy request for the Preview map to get detail of a
    # particular subset of a WMS service. It is the same as preview_proxy
    # but with a slightly different way of cleaning the URL (just removing
    # jsessionid if it is present). Maybe they can be merged.

    url = params[:url]
    throw(:abort) if url.nil?

    # TODO: We don't want to be an open relay. We must ensure this
    # request is coming from a page we served.


    base_wms_url = url.gsub /;jsessionid=[a-z0-9]+/i, ';jsessionid='

    begin
      doc = Nokogiri::XML(open(base_wms_url))
      render xml: doc
    rescue Exception => e
      render nothing: true, status: :bad_request
    end
  end
end
