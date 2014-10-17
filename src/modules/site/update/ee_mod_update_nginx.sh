# Update NGINX configuration for $EE_DOMAIN

function ee_mod_update_nginx()
{
	# Find out information about current NGINX configuration
	EE_SITE_CURRENT_OPTION=$(head -n1 /etc/nginx/sites-available/$EE_DOMAIN | grep "NGINX CONFIGURATION" | rev | cut -d' ' -f3,4,5,6,7 | rev | cut -d ' ' -f2,3,4,5)
	
	# Git commit
	ee_lib_git /etc/nginx/ "Before ee site update: $EE_DOMAIN running on $EE_SITE_CURRENT_OPTION"
		
	# Update NGINX configuration
	ee_lib_echo "Updating $EE_DOMAIN, please wait..."
	
	if [ -f /etc/nginx/sites-available/$EE_DOMAIN ]; then
		# Find out current NGINX configuration header
		ee_nginx_current_header=$(head -n1 /etc/nginx/sites-available/$EE_DOMAIN | grep "NGINX CONFIGURATION")
		
		# Update NGINX configuration header
		if [ "$EE_SITE_UPDATE_OPTION" = "--html" ] || [ "$EE_SITE_UPDATE_OPTION" = "--php" ] || [ "$EE_SITE_UPDATE_OPTION" = "--mysql" ]; then
			ee_nginx_conf=$(echo $EE_SITE_UPDATE_OPTION | cut -c3-)/basic.conf
		elif [ "$EE_SITE_CACHE_OPTION" = "--basic" ] || [ "$EE_SITE_CACHE_OPTION" = "--wpsc" ] || [ "$EE_SITE_CACHE_OPTION" = "--w3tc" ] || [ "$EE_SITE_CACHE_OPTION" = "--wpfc" ]; then
			ee_nginx_conf=$(echo $EE_SITE_UPDATE_OPTION | cut -c3-)/$(echo $EE_SITE_CACHE_OPTION | cut -c3-).conf
		fi
		ee_nginx_update_header=$(head -n1 /usr/share/easyengine/nginx/$ee_nginx_conf | grep "NGINX CONFIGURATION")
		
		# Update Head Line of NGINX conf
		sed -i "s'$ee_nginx_current_header'$ee_nginx_update_header'" /etc/nginx/sites-available/$EE_DOMAIN || ee_lib_error "Unable to update nginx configuration to $EE_SITE_UPDATE_OPTION, $EE_SITE_CACHE_OPTION for $EE_DOMAIN, exit status =" $?

		# Update NGINX conf for HTML site
		if [ "$EE_SITE_CURRENT_OPTION" = "HTML" ]; then
				sed -i 's/access\.log/access.log rt_cache/' /etc/nginx/sites-available/$EE_DOMAIN && \
				sed -i '/index index.html index.htm;$/d' /etc/nginx/sites-available/$EE_DOMAIN && \
				sed -i '/location \/ {/,/}/c \\tindex index.php index.htm index.html;' /etc/nginx/sites-available/$EE_DOMAIN \
				|| ee_lib_error "Unable to update NGINX configuration to $EE_SITE_UPDATE_OPTION $EE_SITE_CACHE_OPTION, exit status =" $?
				
				# Update HTML to PHP MySQL --basic (--wp/--wpsubdir/--wpsubdomain) options
				if [ "$EE_SITE_UPDATE_OPTION" = "--php" ] || [ "$EE_SITE_UPDATE_OPTION" = "--mysql" ] || [ "$EE_SITE_CACHE_OPTION" = "--basic" ]; then
					sed -i '/include common\/locations.conf/i \\tinclude common\/php.conf;' /etc/nginx/sites-available/$EE_DOMAIN \
					|| ee_lib_error "Unable to update NGINX configuration to $EE_SITE_UPDATE_OPTION $EE_SITE_CACHE_OPTION, exit status =" $?
				# Update HTML to --wpsc (--wp/--wpsubdir/--wpsubdomain) options
				elif [ "$EE_SITE_CACHE_OPTION" = "--wpsc" ]; then
					sed -i '/include common\/locations.conf/i \\tinclude common\/wpsc.conf;' /etc/nginx/sites-available/$EE_DOMAIN \
					|| ee_lib_error "Unable to update NGINX configuration to $EE_SITE_UPDATE_OPTION $EE_SITE_CACHE_OPTION, exit status =" $?
				# Update HTML to --w3tc (--wp/--wpsubdir/--wpsubdomain) options
				elif [ "$EE_SITE_CACHE_OPTION" = "--w3tc" ]; then
					sed -i '/include common\/locations.conf/i \\tinclude common\/w3tc.conf;' /etc/nginx/sites-available/$EE_DOMAIN \
					|| ee_lib_error "Unable to update NGINX configuration to $EE_SITE_UPDATE_OPTION $EE_SITE_CACHE_OPTION, exit status =" $?
				# Update HTML to --wpfc (--wp/--wpsubdir/--wpsubdomain) options
				elif [ "$EE_SITE_CACHE_OPTION" = "--wpfc" ]; then
					sed -i '/include common\/locations.conf/i \\tinclude common\/wpfc.conf;' /etc/nginx/sites-available/$EE_DOMAIN \
					|| ee_lib_error "Unable to update NGINX configuration to $EE_SITE_UPDATE_OPTION $EE_SITE_CACHE_OPTION, exit status =" $?
				fi

		# Update PHP MySQL --basic (--wp/--wpsubdir/--wpsubdomain) to --wpsc --w3tc --wpfc options
		elif [ "$EE_SITE_CURRENT_OPTION" = "PHP" ] || [ "$EE_SITE_CURRENT_OPTION" = "MYSQL" ] || [ "$EE_SITE_CURRENT_OPTION" = "WPSINGLE BASIC" ] || [ "$EE_SITE_CURRENT_OPTION" = "WPSUBDIR BASIC" ] || [ "$EE_SITE_CURRENT_OPTION" = "WPSUBDOMAIN BASIC" ]; then
				if [ "$EE_SITE_CACHE_OPTION" = "--wpsc" ]; then
					sed -i 's/include common\/php.conf/include common\/wpsc.conf/' /etc/nginx/sites-available/$EE_DOMAIN \
					|| ee_lib_error "Unable to update NGINX configuration to $EE_SITE_UPDATE_OPTION $EE_SITE_CACHE_OPTION, exit status =" $?
				elif [ "$EE_SITE_CACHE_OPTION" = "--w3tc" ]; then
					sed -i 's/include common\/php.conf/include common\/w3tc.conf/' /etc/nginx/sites-available/$EE_DOMAIN \
					|| ee_lib_error "Unable to update NGINX configuration to $EE_SITE_UPDATE_OPTION $EE_SITE_CACHE_OPTION, exit status =" $?
				elif [ "$EE_SITE_CACHE_OPTION" = "--wpfc" ]; then
					sed -i 's/include common\/php.conf/include common\/wpfc.conf/' /etc/nginx/sites-available/$EE_DOMAIN \
					|| ee_lib_error "Unable to update NGINX configuration to $EE_SITE_UPDATE_OPTION $EE_SITE_CACHE_OPTION, exit status =" $?
				fi

		# Update --wpsc (--wp/--wpsubdir/--wpsubdomain) to --basic --w3tc --wpfc options
		elif [ "$EE_SITE_CURRENT_OPTION" = "WPSINGLE WP SUPER CACHE" ] || [ "$EE_SITE_CURRENT_OPTION" = "WPSUBDIR WP SUPER CACHE" ] || [ "$EE_SITE_CURRENT_OPTION" = "WPSUBDOMAIN WP SUPER CACHE" ]; then
			if [ "$EE_SITE_CACHE_OPTION" = "--basic" ]; then
				sed -i 's/include common\/wpsc.conf/include common\/php.conf/' /etc/nginx/sites-available/$EE_DOMAIN \
				|| ee_lib_error "Unable to update NGINX configuration to $EE_SITE_UPDATE_OPTION $EE_SITE_CACHE_OPTION, exit status =" $?
			elif [ "$EE_SITE_CACHE_OPTION" = "--w3tc" ]; then
				sed -i 's/include common\/wpfc.conf/include common\/w3tc.conf/' /etc/nginx/sites-available/$EE_DOMAIN \
				|| ee_lib_error "Unable to update NGINX configuration to $EE_SITE_UPDATE_OPTION $EE_SITE_CACHE_OPTION, exit status =" $?
			elif [ "$EE_SITE_CACHE_OPTION" = "--wpfc" ]; then
				sed -i 's/include common\/wpsc.conf/include common\/wpfc.conf/' /etc/nginx/sites-available/$EE_DOMAIN \
				|| ee_lib_error "Unable to update NGINX configuration to $EE_SITE_UPDATE_OPTION $EE_SITE_CACHE_OPTION, exit status =" $?
			fi

		# Update --w3tc (--wp/--wpsubdir/--wpsubdomain) to --basic --wpsc --wpfc options
		elif [ "$EE_SITE_CURRENT_OPTION" = "WPSINGLE W3 TOTAL CACHE" ] || [ "$EE_SITE_CURRENT_OPTION" = "WPSUBDIR W3 TOTAL CACHE" ] || [ "$EE_SITE_CURRENT_OPTION" = "WPSUBDOMAIN W3 TOTAL CACHE" ]; then
			if [ "$EE_SITE_CACHE_OPTION" = "--basic" ]; then
				sed -i 's/include common\/w3tc.conf/include common\/php.conf/' /etc/nginx/sites-available/$EE_DOMAIN \
				|| ee_lib_error "Unable to update NGINX configuration to $EE_SITE_UPDATE_OPTION $EE_SITE_CACHE_OPTION, exit status =" $?
			elif [ "$EE_SITE_CACHE_OPTION" = "--wpsc" ]; then
				sed -i 's/include common\/w3tc.conf/include common\/wpsc.conf/' /etc/nginx/sites-available/$EE_DOMAIN \
				|| ee_lib_error "Unable to update NGINX configuration to $EE_SITE_UPDATE_OPTION $EE_SITE_CACHE_OPTION, exit status =" $?
			elif [ "$EE_SITE_CACHE_OPTION" = "--wpfc" ]; then
				sed -i 's/include common\/w3tc.conf/include common\/wpfc.conf/' /etc/nginx/sites-available/$EE_DOMAIN \
				|| ee_lib_error "Unable to update NGINX configuration to $EE_SITE_UPDATE_OPTION $EE_SITE_CACHE_OPTION, exit status =" $?
			fi

		# Update --wpfc (--wp/--wpsubdir/--wpsubdomain) to --basic --wpsc --w3tc options
		elif [ "$EE_SITE_CURRENT_OPTION" = "WPSINGLE FAST CGI" ] || [ "$EE_SITE_CURRENT_OPTION" = "WPSUBDIR FAST CGI" ] || [ "$EE_SITE_CURRENT_OPTION" = "WPSUBDOMAIN FAST CGI" ]; then
			if [ "$EE_SITE_CACHE_OPTION" = "--basic" ]; then
				sed -i 's/include common\/wpfc.conf/include common\/php.conf/' /etc/nginx/sites-available/$EE_DOMAIN \
				|| ee_lib_error "Unable to update NGINX configuration to $EE_SITE_UPDATE_OPTION $EE_SITE_CACHE_OPTION, exit status =" $?
			elif [ "$EE_SITE_CACHE_OPTION" = "--wpsc" ]; then
				sed -i 's/include common\/wpfc.conf/include common\/wpsc.conf/' /etc/nginx/sites-available/$EE_DOMAIN \
				|| ee_lib_error "Unable to update NGINX configuration to $EE_SITE_UPDATE_OPTION $EE_SITE_CACHE_OPTION, exit status =" $?
			elif [ "$EE_SITE_CACHE_OPTION" = "--w3tc" ]; then
				sed -i 's/include common\/wpfc.conf/include common\/w3tc.conf/' /etc/nginx/sites-available/$EE_DOMAIN \
				|| ee_lib_error "Unable to update NGINX configuration to $EE_SITE_UPDATE_OPTION $EE_SITE_CACHE_OPTION, exit status =" $?
			fi
		fi

		# Add WordPress common file wpcommon.conf for HTML PHP & MYSQL sites
		if [[ "$EE_SITE_CURRENT_OPTION" = "HTML" || "$EE_SITE_CURRENT_OPTION" = "PHP" || "$EE_SITE_CURRENT_OPTION" = "MYSQL" ]] && \
			[[ "$EE_SITE_UPDATE_OPTION" = "--wp" || "$EE_SITE_UPDATE_OPTION" = "--wpsubdomain" || "$EE_SITE_UPDATE_OPTION" = "--wpsubdir" ]]; then	
			sed -i '/include common\/locations.conf/i \\tinclude common\/wpcommon.conf;' /etc/nginx/sites-available/$EE_DOMAIN || ee_lib_error "Unable to update nginx configuration to $EE_SITE_UPDATE_OPTION, $EE_SITE_CACHE_OPTION for $EE_DOMAIN, exit status =" $?
		fi

		# Update server_name for HTML PHP MYSQL WP (single site) only
		# Don't execute for WordPress Multisite
		if [ "$EE_SITE_UPDATE_OPTION" = "--wpsubdir" ] || [ "$EE_SITE_UPDATE_OPTION" = "--wpsubdomain" ] \
			&& [ "$EE_SITE_CURRENT_OPTION" != "WPSUBDIR BASIC" ] && [ "$EE_SITE_CURRENT_OPTION" != "WPSUBDOMAIN BASIC" ] \
			&& [ "$EE_SITE_CURRENT_OPTION" != "WPSUBDIR WP SUPER CACHE" ] && [ "$EE_SITE_CURRENT_OPTION" != "WPSUBDOMAIN WP SUPER CACHE" ] \
			&& [ "$EE_SITE_CURRENT_OPTION" != "WPSUBDIR W3 TOTAL CACHE" ] && [ "$EE_SITE_CURRENT_OPTION" != "WPSUBDOMAIN W3 TOTAL CACHE" ] \
			&& [ "$EE_SITE_CURRENT_OPTION" != "WPSUBDIR FAST CGI" ] && [ "$EE_SITE_CURRENT_OPTION" != "WPSUBDOMAIN FAST CGI" ]; then
		
			sed -i "s'server_name $EE_DOMAIN www.$EE_DOMAIN;'server_name $EE_DOMAIN *.$EE_DOMAIN;'" /etc/nginx/sites-available/$EE_DOMAIN && \
			sed -i '/server_name.*;/i \\t# Uncomment the following line for domain mapping;\n\t# listen 80 default_server;\n' /etc/nginx/sites-available/$EE_DOMAIN && \
			sed -i '/server_name.*;/a \\n\t# Uncomment the following line for domain mapping \n\t#server_name_in_redirect off;' /etc/nginx/sites-available/$EE_DOMAIN && \
			sed -i '/include common\/locations.conf/i \\tinclude common\/wpsubdir.conf;' /etc/nginx/sites-available/$EE_DOMAIN || ee_lib_error "Unable to update nginx configuration to $EE_SITE_UPDATE_OPTION, $EE_SITE_CACHE_OPTION for $EE_DOMAIN, exit status =" $?
		fi
	else
		ee_lib_error "Unable to find $EE_DOMAIN NGINX configuration, exit status =" $?
	fi
}
