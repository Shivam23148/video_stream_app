import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/config/service_locator.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/core/service/auth_service.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/core/theme/color_palette.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/shared/utils/snackbar_util.dart';
import 'package:ntavideofeedapp/main.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/router/route_names.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  void copyToClipBoard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    SnackbarUtil.showSnackbar(
      message: "Copied to clipboard!",
      backgroundColor: Colors.grey.shade500,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(serviceLocator<DeviceFlowAuthService>()),
      child: Scaffold(
        appBar: AppBar(),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) async {
            logger.i("Auth screen state: $state");
            if (state is AuthFailure) {
              SnackbarUtil.showSnackbar(
                message: "Login Failure: Something went wrong",
                backgroundColor: AppColor.unsuccessfulColor,
              );

              logger.e("Login Fail error: ${state.emessage}");
            }

            if (state is DeviceVerificationSendState) {
              SnackbarUtil.showSnackbar(
                message: "Verification Sent Successfuly",
                backgroundColor: AppColor.successfulColor,
              );
            }
            if (state is AuthSuccess) {
              final sp = await SharedPreferences.getInstance();
              final isLangSelected =
                  sp.getBool('is_language_selected') ?? false;
              logger.d("Lanuage selected bool value is $isLangSelected");
              if (!isLangSelected) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.onboardingRoute,
                  (_) => false,
                );
              } else {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.homeRoute,
                  (_) => false,
                );

                SnackbarUtil.showSnackbar(
                  message: "Login Successful",
                  backgroundColor: AppColor.successfulColor,
                );
              }
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return Center(child: CircularProgressIndicator());
            }
            /* if (state is AuthShowVerification) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  QrImageView(
                    data: state.qrCodeUrl,
                    size: 180,
                    backgroundColor: Colors.white,
                  ),
                  Container(height: 180, width: 2, color: Colors.grey.shade500),
                  SizedBox(width: 5),
                  Flexible(
                    child: SizedBox(
                      height: 180,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onLongPress: () =>
                                copyToClipBoard(context, state.verificationUrl),
                            onTap: () =>
                                launchUrl(Uri.parse(state.verificationUrl)),
                            child: Text(
                              state.verificationUrl,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.lightBlueAccent,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Enter Code:",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          InkWell(
                            onLongPress: () =>
                                copyToClipBoard(context, state.userCode),
                            child: Text(
                              state.userCode,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
              /*  return _buildVerification(context, state); */
            }
          */
            if (state is DeviceVerificationSendState) {
              return Center(child: Icon(Icons.check_circle_rounded));
            }
            if (state is AuthAskEmailRequestState) {
              final TextEditingController email = TextEditingController();
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
                    child: TextField(
                      controller: email,
                      decoration: InputDecoration(
                        hintText: 'Enter Email',
                        fillColor: Colors.transparent,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColor.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColor.borderColor),
                        ),
                      ),
                      cursorColor: AppColor.primaryTextColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      context.read<AuthBloc>().add(
                        EmailRequestEvent(email.text.trim()),
                      );
                    },
                    child: Text("Send Verification"),
                  ),
                ],
              );
            }
            if (state is AuthInitial) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(LoginStartedEvent());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 40,
                    ),
                    textStyle: const TextStyle(fontSize: 24),
                  ),
                  child: const Text("Login with Device Code"),
                ),
              );
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildVerification(BuildContext context, AuthShowVerification state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 600;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: isSmall
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildSplitContent(context, state, isSmall: true),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildSplitContent(
                      context,
                      state,
                      isSmall: false,
                    ),
                  ),
          ),
        );
      },
    );
  }

  List<Widget> _buildSplitContent(
    BuildContext context,
    AuthShowVerification state, {
    required bool isSmall,
  }) {
    return [
      QrImageView(
        data: state.qrCodeUrl,
        size: isSmall ? 180 : 250,
        backgroundColor: Colors.white,
      ),
      if (!isSmall)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: VerticalDivider(color: Colors.grey, thickness: 2, width: 40),
        )
      else
        const SizedBox(height: 16),
      SizedBox(
        width: isSmall ? double.infinity : 300,
        child: Column(
          crossAxisAlignment: isSmall
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            const Text(
              "Go to this URL:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: InkWell(
                    onTap: () => launchUrl(Uri.parse(state.verificationUrl)),
                    child: Text(
                      state.verificationUrl,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.lightBlueAccent,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () => copyToClipBoard(context, state.verificationUrl),
                  child: const Icon(Icons.copy, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Enter Code:",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  state.userCode,
                  style: TextStyle(
                    fontSize: isSmall ? 36 : 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () => copyToClipBoard(context, state.userCode),
                  child: const Icon(Icons.copy, size: 24),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }
}
