import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gx_gam/flutter_gx_gam.dart';

/// State para controlar permisos en pantalla
abstract class GAMState<T extends StatefulWidget> extends State<T> {
  String permissionName;
  String roleName;
  bool showProgress = true;

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    return FutureBuilder<ServiceErrorResponse>(
      future: GAMService.isAuthorized(
          permissionName: permissionName, roleName: roleName),
      builder: (ctx, snapshot) {
        if (snapshot.hasError) {
          return Container();
        } else {
          if (snapshot.hasData) {
            if (GAMConfig().debug)
              print("GAM.state " +
                  snapshot.data.code +
                  "- " +
                  snapshot.data.message);
            switch (snapshot.data.code) {
              case "200":
                return buildAuthorized(context);
                break;
              case "401":
              case "103": // lo retorna GAM cuando es 401
                @override
                void run() {
                  scheduleMicrotask(() {
                    Navigator.pushReplacementNamed(
                        context, GAMConfig().loginRoute);
                  });
                }
                run();
                return Container();
                break;
              case "403":
                return buildNotAuthorized(context);
                break;
              default:
                return Container();
            }
          } else {
            return (showProgress)
                ? Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                    CircularProgressIndicator(),
                  ]))
                : Container();
          }
        }
      },
    );
  }

  Widget buildAuthorized(BuildContext context);
  Widget buildNotAuthorized(BuildContext context);
}
