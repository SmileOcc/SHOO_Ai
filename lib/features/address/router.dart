import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/hos_routes.dart';
import 'presentation/hos_address_form_page.dart';
import 'presentation/hos_address_list_page.dart';

List<RouteBase> shoAddressRoutes({required GlobalKey<NavigatorState> rootKey}) => [
      GoRoute(
        path: SHOAppRoutes.addresses,
        parentNavigatorKey: rootKey,
        builder: (context, state) => SHOAddressListPage(
          selectMode: state.uri.queryParameters['select'] == '1',
        ),
        routes: [
          GoRoute(
            path: 'form',
            parentNavigatorKey: rootKey,
            builder: (context, state) => SHOAddressFormPage(
              addressId: state.uri.queryParameters['id'],
            ),
          ),
        ],
      ),
    ];
