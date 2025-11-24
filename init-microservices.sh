for dir in */ ; do
  if [ -f "$dir/build.gradle" ]; then
    echo "Inicializando repo en: $dir"
    cd "$dir"
    git init
    git add .
    git commit -m "Initial commit auto script"

    # Seleccionar repo remoto según la carpeta
    case "$dir" in
      "ms-pedidos/" )
        git remote add origin https://github.com/Franksall/ms-pedidos.git
        ;;
      "ms-productos/" )
        git remote add origin https://github.com/Franksall/ms-productos.git
        ;;
      "gateway-service/" )
        git remote add origin https://github.com/Franksall/gateway-service.git
        ;;
      "registry-service/" )
        git remote add origin https://github.com/Franksall/registry-service.git
        ;;
      "ms-config-server/" )
        git remote add origin https://github.com/Franksall/ms-config-server.git
        ;;
      "config-repo/" )
        git remote add origin https://github.com/Franksall/config-repo.git
        ;;
      "ms-authorization-server/" )
        git remote add origin https://github.com/Franksall/ms-authorization-server.git
        ;;
    esac

    git branch -M main
    git push -f origin main
    cd ..
    echo "✔ Subido: $dir"
    echo "--------------------------"
  fi
done
