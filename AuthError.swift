// AuthError.swift
import Foundation

enum AuthError: Error {
    case networkError
    case invalidResponse
    case unauthorized
    case tokenExpired
}
