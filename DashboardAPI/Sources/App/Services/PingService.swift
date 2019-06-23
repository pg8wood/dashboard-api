import Vapor

public enum NetworkError: Error {
    case InvalidUrl
    case NoResponse
}

final class PingService {
    public static func fetchServerStatus(url: String, eventLoop: EventLoop) -> Promise<Int> {
        let promise = eventLoop.newPromise(Int.self)
        
        guard let url = URL(string: url) else {
            promise.fail(error: NetworkError.InvalidUrl)
            return promise
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        
        let task = URLSession.shared.dataTask(with: request) { (_ data, response, error) in
            if let error = error {
                promise.fail(error: error)
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                promise.fail(error: NetworkError.NoResponse)
                return
            }
            
            promise.succeed(result: response.statusCode)
        }
        
        task.resume()
        return promise
    }
}
