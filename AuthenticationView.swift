//
//  AuthenticationView.swift
//  paro
//
//  Authentication screen for email/password login
//

import SwiftUI

/**
 Authentication view for user sign-in.

 Displays a minimal authentication screen consistent with Eater's design.
 Shows after user taps the carrot icon if not authenticated.

 ## Features
 - Email/password authentication
 - Simple, minimal design matching app aesthetic
 - Loading states
 - Error handling
 - Auto-dismiss on success

 ## Usage
 ```swift
 .sheet(isPresented: $showAuth) {
     AuthenticationView { success in
         if success {
             // User authenticated, continue to main flow
         }
     }
 }
 ```
 */
struct AuthenticationView: View {
    // MARK: - Properties

    /// Environment dismiss action
    @Environment(\.dismiss) private var dismiss

    /// Callback when authentication succeeds
    var onAuthenticated: ((Bool) -> Void)?

    // MARK: - State

    /// User's email input
    @State private var email = ""

    /// User's password input
    @State private var password = ""

    /// Indicates loading state during authentication
    @State private var isLoading = false

    /// Error message to display
    @State private var errorMessage: String?

    /// Controls error alert visibility
    @State private var showError = false

    /// Toggle between sign in and sign up
    @State private var isSignUp = false

    /// Optional display name for sign up
    @State private var displayName = ""

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // MARK: - Header Section
                VStack(spacing: geometry.size.height * 0.03) {
                    // Carrot icon
                    Image(systemName: "carrot.fill")
                        .font(.system(size: min(geometry.size.width * 0.15, 80)))
                        .foregroundColor(.black)
                        .padding(.top, geometry.size.height * 0.08)

                    // Title
                    Text(isSignUp ? "Create Account" : "Sign In")
                        .font(.system(size: min(geometry.size.width * 0.1, 50), weight: .black))
                        .foregroundColor(.black)

                    // Subtitle
                    Text("to continue ordering")
                        .font(.system(size: min(geometry.size.width * 0.05, 20), weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(.bottom, geometry.size.height * 0.06)

                // MARK: - Form Section
                VStack(spacing: geometry.size.height * 0.025) {
                    // Display name (only for sign up)
                    if isSignUp {
                        TextField("Name", text: $displayName)
                            .textFieldStyle(CustomTextFieldStyle())
                            .autocapitalization(.words)
                            .padding(.horizontal, 30)
                    }

                    // Email field
                    TextField("Email", text: $email)
                        .textFieldStyle(CustomTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .padding(.horizontal, 30)

                    // Password field
                    SecureField("Password", text: $password)
                        .textFieldStyle(CustomTextFieldStyle())
                        .padding(.horizontal, 30)

                    // Action button
                    Button(action: handleAuthentication) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }

                            Text(isLoading ? "Please wait..." : (isSignUp ? "Sign Up" : "Sign In"))
                                .font(.system(size: min(geometry.size.width * 0.055, 22), weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: geometry.size.height * 0.07)
                        .background(Color.black)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, geometry.size.height * 0.02)
                    .disabled(isLoading || !isFormValid)
                    .opacity((isLoading || !isFormValid) ? 0.6 : 1.0)

                    // Toggle sign in/sign up
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isSignUp.toggle()
                            errorMessage = nil
                        }
                    }) {
                        HStack(spacing: 5) {
                            Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                                .font(.system(size: min(geometry.size.width * 0.04, 16)))
                                .foregroundColor(.gray)

                            Text(isSignUp ? "Sign In" : "Sign Up")
                                .font(.system(size: min(geometry.size.width * 0.04, 16), weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.top, 10)
                }

                Spacer()

                // MARK: - Skip Button
                Button(action: {
                    // Allow skipping authentication for now
                    dismiss()
                }) {
                    Text("Skip for now")
                        .font(.system(size: min(geometry.size.width * 0.045, 18)))
                        .foregroundColor(.gray)
                        .underline()
                }
                .padding(.bottom, geometry.size.height * 0.05)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .toolbar(.hidden, for: .navigationBar)
        .ignoresSafeArea(.keyboard)
        .alert("Authentication Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An error occurred")
        }
    }

    // MARK: - Computed Properties

    /**
     Validates if the form is ready for submission.

     - Returns: true if all required fields are filled
     */
    private var isFormValid: Bool {
        if isSignUp {
            return !email.isEmpty && !password.isEmpty && !displayName.isEmpty && password.count >= 6
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }

    // MARK: - Actions

    /**
     Handles authentication (sign in or sign up).

     Calls AuthService to authenticate the user, then dismisses on success.
     */
    private func handleAuthentication() {
        // Clear any previous errors
        errorMessage = nil

        // Start loading
        isLoading = true

        if isSignUp {
            // Sign up flow
            AuthService.shared.signUp(
                email: email,
                password: password,
                displayName: displayName
            ) { result in
                handleAuthResult(result)
            }
        } else {
            // Sign in flow
            AuthService.shared.signIn(
                email: email,
                password: password
            ) { result in
                handleAuthResult(result)
            }
        }
    }

    /**
     Handles authentication result.

     - Parameter result: Result from AuthService
     */
    private func handleAuthResult(_ result: Result<User, AuthError>) {
        DispatchQueue.main.async {
            isLoading = false

            switch result {
            case .success(let user):
                print("✅ Authentication successful: \(user.uid)")

                // Call success callback
                onAuthenticated?(true)

                // Dismiss the view
                dismiss()

            case .failure(let error):
                print("❌ Authentication failed: \(error.localizedDescription)")

                // Show error to user
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

// MARK: - Custom Text Field Style

/**
 Custom text field style matching Eater's minimal design.
 */
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.black.opacity(0.2), lineWidth: 1)
            )
            .font(.system(size: 16))
    }
}

// MARK: - Preview

#Preview {
    AuthenticationView()
}
