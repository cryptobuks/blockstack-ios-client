//
//  Blockstack.swift
//  Blockstack
//
//  Created by Jorge Tapia on 8/25/16.
//  Copyright © 2016 Blockstack.org. All rights reserved.
//

import Foundation

/// iOS client for blockstack-server.
public class Blockstack {
    
    /// Onename API app id.
    fileprivate var appId: String?
    
    /// Onename API app secret.
    fileprivate var appSecret: String?
    
    /// Initializes the Blockstack client for iOS.
    /// - Parameters:
    ///     - appId: The app id obtained from the [Onename API](http://api.onename.com).
    ///     - appSecret: The app secrect obtained from the [Onename API](http://api.onename.com).
    public init(appId: String, appSecret: String) {
        self.appId = appId
        self.appSecret = appSecret
    }
    
    /// Processes the app id and app secret into a valid Authorization header value.
    ///
    /// - Returns: A valid Authorization header value based on the app id and app secret.
    fileprivate func getAuthorizationValue() -> String? {
        let credentialsString = "\(self.appId):\(self.appSecret)"
        let credentialsData = credentialsString.data(using: .utf8)
        
        
        return "Basic \(credentialsData?.base64EncodedData(options: []))"
    }
    
}

// MARK: - User operations

extension Blockstack {
    
    /// Looks up the data for one or more users by their usernames.
    ///
    /// - Parameters:
    ///     - users: Username(s) to look up.
    ///     - completion: Closure containing an object with a top-level key for each username looked up or an error.
    ///                   Each top-level key contains an sub-object that has a "profile" field and a "verifications" field.
    public func lookup(_ users: [String], completion: @escaping (_ response: Data?, _ error: Error?) -> Void) {
        if let authorizationValue = getAuthorizationValue() {
            let lookupEndpoint = "\(Endpoints.users)/\(users.joined(separator: ","))"
            
            var request = URLRequest(url: URL(string: lookupEndpoint)!)
            request.addValue(authorizationValue, forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let data = data {
                    completion(data, error)
                }
            }).resume()
        }
    }
    
    /// Takes in a search query and returns a list of results that match the search.
    /// The query is matched against +usernames, full names, and twitter handles by default.
    /// It's also possible to explicitly search verified Twitter, Facebook, Github accounts, and verified domains.
    /// This can be done by using search queries like twitter:itsProf, facebook:g3lepage, github:shea256, domain:muneebali.com
    ///
    /// - Parameters:
    ///     - query: The text to search for.
    ///     - completion: Closure containing an array of results, where each result has a "profile" object or an error.
    public func search(_ query: String, completion: @escaping (_ response: Data?, _ error: Error?) -> Void) {
        if let authorizationValue = getAuthorizationValue() {
            let searchEndpoint = "\(Endpoints.search)\(query)"
            
            var request = URLRequest(url: URL(string: searchEndpoint)!)
            request.addValue(authorizationValue, forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let data = data {
                    completion(data, error)
                }
            }).resume()
        }
    }
    
    /// Registers a username.
    ///
    /// - Parameters:
    ///     - username: The username to be registered.
    ///     - recipientAddress: Bitcoin address of the new owner address.
    ///     - profileData: The data to be associated with the blockchain ID.
    ///     - completion: Closure a response that could include an object with an unsigned transaction "unsigned_tx" in hex format.
    public func registerUser(_ username: String, recipientAddress: String, profileData: [String: Any]?, completion: @escaping (_ response: Data?, _ error: Error?) -> Void) {
        if let authorizationValue = getAuthorizationValue() {
            var params: [String: Any] = ["username": username, "recipient_address": recipientAddress]
            
            if let profile = profileData {
                params["profile"] = profile
            }
            
            do {
                var request = URLRequest(url: URL(string: Endpoints.users)!)
                request.addValue(authorizationValue, forHTTPHeaderField: "Authorization")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
                
                URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                    if let data = data {
                        completion(data, error)
                    }
                }).resume()
            } catch {
                debugPrint(error.localizedDescription, error)
            }
        }
    }
    
    /// Updates a username.
    ///
    /// - Parameters:
    ///     - username: The username to be updated.
    ///     - profileData: The data to be associated with the blockchain ID.
    ///     - ownerPublicKey: Public key of the Bitcoin address that currently owns the username.
    ///     - completion: Closure with a response that could include an object with an unsigned transaction "unsigned_tx" in hex format.
    public func updateUser(_ username: String, profileData: [String: AnyObject], ownerPublicKey: String, completion: @escaping (_ response: Data?, _ error: Error?) -> Void) {
        if let authorizationValue = getAuthorizationValue() {
            let updateEndpoint = "\(Endpoints.users)/\(username)/update)"
            let params: [String: Any] = ["profile": profileData, "owner_pubkey": ownerPublicKey]
            
            do {
                var request = URLRequest(url: URL(string: updateEndpoint)!)
                request.addValue(authorizationValue, forHTTPHeaderField: "Authorization")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
                
                URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                    if let data = data {
                        completion(data, error)
                    }
                }).resume()
            } catch {
                debugPrint(error.localizedDescription, error)
            }
        }
    }
    
    /// Transfers a user to another Bitcoin address.
    ///
    /// - Parameters:
    ///     - username: The username to be transfered.
    ///     - transferAddress: Bitcoin address of the new owner address.
    ///     - ownerPublicKey: Public key of the Bitcoin address that currently owns the username.
    ///     - completion: Closure with a response that could include an object with an unsigned transaction "unsigned_tx" in hex format.
    public func transferUser(_ username: String, transferAddress: String, ownerPublicKey: String, completion: @escaping (_ response: Data?, _ error: Error?) -> Void) {
        if let authorizationValue = getAuthorizationValue() {
            let updateEndpoint = "\(Endpoints.users)/\(username)/update)"
            let params: [String: Any] = ["transfer_address": transferAddress, "owner_pubkey": ownerPublicKey]
            
            do {
                var request = URLRequest(url: URL(string: updateEndpoint)!)
                request.addValue(authorizationValue, forHTTPHeaderField: "Authorization")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
                
                URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                    if let data = data {
                        completion(data, error)
                    }
                }).resume()
            } catch {
                debugPrint(error.localizedDescription, error)
            }
        }
    }
    
    /// Returns an object with "stats", and "usernames".
    /// "stats" is a sub-object which in turn contains a "registrations" field that reflects a running count of the total users registered.
    /// "usernames" is a list of all usernames in the namespace.
    ///
    /// - Parameter completion: Closure with and object that contains "stats" and "usernames" or an error.
    public func allUsers(_ completion: @escaping (_ response: Data?, _ error: Error?) -> Void) {
        if let authorizationValue = getAuthorizationValue() {
            var request = URLRequest(url: URL(string: Endpoints.users)!)
            request.addValue(authorizationValue, forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let data = data {
                    completion(data, error)
                }
            }).resume()
        }
    }
    
}

// MARK: - Transaction operations

extension Blockstack {
    
    /// Takes in a signed transaction (in hex format) and broadcasts it to the network.
    /// If the transaction is successfully broadcasted, the transaction hash is returned in the response.
    ///
    /// - Parameter signedTransaction: A signed transaction in hex format.
    /// - Parameter completion: Closure with and object that contains a Blockstack server response with a status that is either "success" or "error".
    public func broadcastTransaction(_ signedTransaction: String, completion: @escaping (_ response: Data?, _ error: Error?) -> Void) {
        if let authorizationValue = getAuthorizationValue() {
            let params = ["signed_hex": signedTransaction]
            
            do {
                var request = URLRequest(url: URL(string: Endpoints.transactions)!)
                request.addValue(authorizationValue, forHTTPHeaderField: "Authorization")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
                
                URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                    if let data = data {
                        completion(data, error)
                    }
                }).resume()
            } catch {
                debugPrint(error.localizedDescription, error)
            }
        }
    }
    
}

// MARK: - Address operations

extension Blockstack {
    
    /// Retrieves the unspent outputs for a given address so they can be used for building transactions.
    ///
    /// - Parameters:
    ///     - address: The address to look up unspent outputs for.
    ///     - completion: Closure with an array of unspent outputs for a provided address or an error.
    public func unspentOutputs(forAddress address: String, completion: @escaping (_ response: Data?, _ error: Error?) -> Void) {
        if let authorizationValue = getAuthorizationValue() {
            let unspentOutputsEndpoint = "\(Endpoints.addresses)/\(address)/unspents"
            
            var request = URLRequest(url: URL(string: unspentOutputsEndpoint)!)
            request.addValue(authorizationValue, forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let data = data {
                    completion(data, error)
                }
            }).resume()
        }
    }
    
    /// Retrieves a list of names owned by the address provided.
    ///
    /// - Parameters:
    ///     - address: The address to look up names owned by.
    ///     - completion: Closure with an array of the names that the address owns or an error.
    public func namesOwned(byAddress address: String, completion: @escaping (_ response: Data?, _ error: Error?) -> Void) {
        if let authorizationValue = getAuthorizationValue() {
            let namesOwnedEndpoint = "\(Endpoints.addresses)/\(address)/names"
            
            var request = URLRequest(url: URL(string: namesOwnedEndpoint)!)
            request.addValue(authorizationValue, forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let data = data {
                    completion(data, error)
                }
            }).resume()
        }
    }
    
}

// MARK: - Domain operations

extension Blockstack {
    
    /// Retrieves a DKIM public key for given domain, using the "blockchainid._domainkey" subdomain DNS record.
    ///
    /// - Parameters:
    ///     - domain: The domain to loop up the DKIM key for.
    ///     - completion: Closure with a DKIM public key or error.
    public func dkimPublicKey(forDomain domain: String, completion: @escaping (_ response: Data?, _ error: Error?) -> Void) {
        if let authorizationValue = getAuthorizationValue() {
            let dkimPublicKeyEndpoint = "\(Endpoints.domains)/\(domain)/dkim"
            
            var request = URLRequest(url: URL(string: dkimPublicKeyEndpoint)!)
            request.addValue(authorizationValue, forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let data = data {
                    completion(data, error)
                }
            }).resume()
        }
    }
    
}
