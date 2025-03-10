checkVideoUrl(String url) {
  return url.toString().toUpperCase().contains('.MP4') ||
      url.toString().toUpperCase().contains('.MOV') ||
      url.toString().toUpperCase().contains('.AVI') ||
      url.toString().toUpperCase().contains('.MKV') ||
      url.toString().toUpperCase().contains('.WEBM') ||
      url.toString().toUpperCase().contains('.FLV') ||
      url.toString().toUpperCase().contains('.WMV') ||
      url.toString().toUpperCase().contains('.3GP') ||
      url.toString().toUpperCase().contains('.3GPP');
}
