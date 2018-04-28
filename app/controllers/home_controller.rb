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

    # We don't want to be an open relay. Assert for now the host we're receiving this
    # request from
    if !['127.0.0.1', 'localhost'].include?(request.host) || request.host.end_with?('cloudapps.digital')
      return render nothing: true, status: 404
    end

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
    # This needs converting to Ruby ....
=begin
  '''
        This is a proxy request for the Preview map to get detail of a
        particular subset of a WMS service.
        Example request:
        http://dev-ckan.dgu.coi.gov.uk/data/preview_getinfo?url=http%3A%2F%2Flasigpublic.nerc-lancaster.ac.uk%2FArcGIS%2Fservices%2FBiodiversity%2FGMFarmEvaluation%2FMapServer%2FWMSServer%3FLAYERS%3DWinterOilseedRape%26QUERY_LAYERS%3DWinterOilseedRape%26STYLES%3D%26SERVICE%3DWMS%26VERSION%3D1.1.1%26REQUEST%3DGetFeatureInfo%26EXCEPTIONS%3Dapplication%252Fvnd.ogc.se_xml%26BBOX%3D-1.628338%252C52.686046%252C-0.086204%252C54.8153%26FEATURE_COUNT%3D11%26HEIGHT%3D845%26WIDTH%3D612%26FORMAT%3Dimage%252Fpng%26INFO_FORMAT%3Dapplication%252Fvnd.ogc.wms_xml%26SRS%3DEPSG%253A4258%26X%3D327%26Y%3D429
        and that url parameter value unquotes to:
        http://lasigpublic.nerc-lancaster.ac.uk/ArcGIS/services/Biodiversity/GMFarmEvaluation/MapServer/WMSServer?LAYERS=WinterOilseedRape&QUERY_LAYERS=WinterOilseedRape&STYLES=&SERVICE=WMS&VERSION=1.1.1&REQUEST=GetFeatureInfo&EXCEPTIONS=application%2Fvnd.ogc.se_xml&BBOX=-1.628338%2C52.686046%2C-0.086204%2C54.8153&FEATURE_COUNT=11&HEIGHT=845&WIDTH=612&FORMAT=image%2Fpng&INFO_FORMAT=application%2Fvnd.ogc.wms_xml&SRS=EPSG%3A4258&X=327&Y=429
        '''
        # avoid status_code_redirect intercepting error responses
        request.environ['pylons.status_code_redirect'] = False

        wms_url = request.params.get('url')

        # Check parameter
        if not (wms_url):
            response.status_int = 400
            return 'Missing url parameter'

        # Check base of URL is in CKAN (otherwise we are an open proxy)
        # (the parameters get changed by the Preview widget)
        base_wms_url = get_wms_base_url(wms_url)
        query = model.Session.query(model.Resource).filter(model.Resource.url.like(base_wms_url+'%'))
        if query.count() == 0:
            # Try in the 'wms_base_urls' extras too, as some WMSs use different
            # bases (specified in their GetCapabilities response)
            model_attr = getattr(model.Resource, 'extras')
            field = 'wms_base_urls'
            term = base_wms_url #.replace('/', '\\/').replace(':', '\\:')
            like = sqlalchemy.or_(
                model_attr.ilike(u'''%%"%s": "%%%s%%",%%''' % (field, term)),
                model_attr.ilike(u'''%%"%s": "%%%s%%"}''' % (field, term))
            )
            q = model.Session.query(model.Resource).filter(like)
            if q.count() == 0:
                response.status_int = 403
                return 'Base of WMS URL not known: %r' % base_wms_url

        content = self._read_url(wms_url)
        if not content:
            # Varnish will change an empty response into a 500 Guru
            # meditation  (see "small blank pages" in the vcl), so return an
            # error message instead
            return 'Server returned 0 bytes'

return content
=end
  end

end
