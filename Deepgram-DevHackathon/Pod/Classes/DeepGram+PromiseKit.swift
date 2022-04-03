import PromiseKit

extension DGClient {

    public func getBalance(progress: ((NSProgress) -> Void)?) -> Promise<Float> {
        return Promise { fulfill, reject in
            self.getBalanceWithProgress(progress, success: { task, number in
                fulfill(number.floatValue)
            }, failure:  { task, error  in
                reject(error)
            })
        }
    }

    public func indexURL(audioURL: NSURL, progress: ((NSProgress) -> Void)?) -> Promise<String> {
        return Promise { fulfill, reject in
            self.indexURL(audioURL, progress: progress, success: { task, content in
                fulfill(content)
            }, failure: { task, error  in
                reject(error)
            })
        }
    }


    public func statusOfContent(contentID: String, progress: ((NSProgress) -> Void)?) -> Promise<DGIndexStatus> {
        return Promise { fulfill, reject in
            self.statusOfContent(contentID, progress: progress, success: { task, status in
                fulfill(DGIndexStatus(rawValue: status.unsignedIntegerValue)!)
            }, failure: { task, error in
                reject(error)
            })
        }
    }


    public func matchesInContent(contentID: String, query: String, snippet: Bool, Nmax: Float?, confidenceMin: Float?, progress: ((NSProgress) -> Void)?) -> Promise<Array<DGMatch>> {
        return Promise { fulfill, reject in
            self.matchesInContent(contentID, withQuery: query, snippet: snippet, nmax: Nmax, confidenceMin: confidenceMin, progress: progress, success: { task, matches in
                fulfill(matches)
            }, failure: { task, error in
                reject(error)
            })
        }
    }


    public func transcriptForContent(contentID: String, progress: ((NSProgress) -> Void)?) -> Promise<Dictionary<NSNumber, String>> {
        return Promise { fulfill, reject in
            self.transcriptForContent(contentID, progress: progress, success: { task, paragraphs in
                fulfill(paragraphs)
            }, failure: { task, error in
                reject(error)
            })
        }
    }
    

    public func searchAllContent(query: String, tag: String?, Nmax: Float?, confidenceMin: Float?, progress: ((NSProgress) -> Void)?) -> Promise<Array<DGMatch>> {
        return Promise { fulfill, reject in
            self.searchAllContentWithQuery(query, tag: tag, nmax: Nmax, confidenceMin: confidenceMin, progress: progress, success: { task, matches in
                fulfill(matches)
            }, failure: { task, error in
                reject(error)
            })
        }
    }
}
