// MARK: - image async load

extension UIImageView {
    
    func image(from urlString: String) {
        guard let url = URL(string: urlString) else {
            self.image = nil
            return
        }
        
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            if let err = error {
                print(err)
                self.image = nil
                return
            }
            
            guard let d = data else {
                self.image = nil
                return
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: d)
                self.image = image
            })
        }).resume()
    }
    
}
