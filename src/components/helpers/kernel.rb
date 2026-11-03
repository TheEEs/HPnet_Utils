class String
    def ellipsis(max_length: 30, ellipsis_string: "...")
        return self if length <= max_length
        self[0, max_length] + ellipsis_string
    end    
end