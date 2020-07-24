FROM r.j3ss.co/img:v0.5.9

LABEL maintainer="İbrahim Akyel <ibrahim@ibrahimakyel.com>" \
	org.label-schema.name="Drone Img" \
	org.label-schema.vendor="İbrahim Akyel" \
	org.label-schema.schema-version="1.0"

COPY plugin.sh /img/plugin.sh

ENTRYPOINT ["/img/plugin.sh"]
